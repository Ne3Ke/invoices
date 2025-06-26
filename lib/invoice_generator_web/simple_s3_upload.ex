defmodule SimpleS3Upload do
  @moduledoc """
  Dependency-free S3 Form Upload using HTTP POST sigv4
  https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-post-example.html
  """

  @doc """
  Signs a form upload.
  The configuration is a map which must contain the following keys:
  config = %{
    * `:region` - The AWS region, such as "us-east-1"
    * `:access_key_id` - The AWS access key id
    * `:secret_access_key` - The AWS secret access key
    }
  Returns a map of form fields to be used on the client via the JavaScript `FormData` API.
  ## Options
    * `:key` - The required key of the object to be uploaded.
    * `:max_file_size` - The required maximum allowed file size in bytes.
    * `:content_type` - The required MIME type of the file to be uploaded.
    * `:expires_in` - The required expiration time in milliseconds from now
      before the signed upload expires.
  ## Examples
      {:ok, fields} =
        SimpleS3Upload.sign_form_upload(
          key: "public/my-file-name",
          content_type: "image/png",
          max_file_size: 10_000,
          expires_in: :timer.hours(1)
        )
  """
  def sign_form_upload(opts) do
    key = Keyword.fetch!(opts, :key)
    max_file_size = Keyword.fetch!(opts, :max_file_size)
    content_type = Keyword.fetch!(opts, :content_type)
    expires_in = Keyword.fetch!(opts, :expires_in)

    expires_at = DateTime.add(DateTime.utc_now(), expires_in, :millisecond)
    amz_date = amz_date(expires_at)
    credential = credential(config(), expires_at)

    encoded_policy =
      Base.encode64("""
      {
        "expiration": "#{DateTime.to_iso8601(expires_at)}",
        "conditions": [
          {"bucket":  "#{bucket()}"},
          ["eq", "$key", "#{key}"],
          {"acl": "public-read"},
          ["eq", "$Content-Type", "#{content_type}"],
          ["content-length-range", 0, #{max_file_size}],
          {"x-amz-server-side-encryption": "AES256"},
          {"x-amz-credential": "#{credential}"},
          {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
          {"x-amz-date": "#{amz_date}"}
        ]
      }
      """)

    fields = %{
      "key" => key,
      "acl" => "public-read",
      "content-type" => content_type,
      "x-amz-server-side-encryption" => "AES256",
      "x-amz-credential" => credential,
      "x-amz-algorithm" => "AWS4-HMAC-SHA256",
      "x-amz-date" => amz_date,
      "policy" => encoded_policy,
      "x-amz-signature" => signature(config(), expires_at, encoded_policy)
    }

    {:ok, fields}
  end

  def config do
    %{
      region: region(),
      access_key_id: Application.fetch_env!(:invoice_generator, :access_key_id),
      secret_access_key: Application.fetch_env!(:invoice_generator, :secret_access_key)
      # secret_access_key: System.fetch_env!("S3_SECRET_ACCESS_KEY")
    }
  end

  def bucket do
    # System.fetch_env!("S3_BUCKET")
    Application.fetch_env!(:invoice_generator, :bucket)
  end

  def region do
    # System.fetch_env!("S3_REGION")
    Application.fetch_env!(:invoice_generator, :region)
  end

  # def entry_url(entry) do
  #   "http://#{bucket()}.s3.#{region()}.amazonaws.com/#{entry.uuid}.#{ext(entry)}"
  # end

  def s3_filepath(entry) do
    "#{entry.uuid}.#{ext(entry)}"
  end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  defp amz_date(time) do
    time
    |> NaiveDateTime.to_iso8601()
    |> String.split(".")
    |> List.first()
    |> String.replace("-", "")
    |> String.replace(":", "")
    |> Kernel.<>("Z")
  end

  defp credential(%{} = config, %DateTime{} = expires_at) do
    "#{config.access_key_id}/#{short_date(expires_at)}/#{config.region}/s3/aws4_request"
  end

  defp signature(config, %DateTime{} = expires_at, encoded_policy) do
    config
    |> signing_key(expires_at, "s3")
    |> sha256(encoded_policy)
    |> Base.encode16(case: :lower)
  end

  defp signing_key(%{} = config, %DateTime{} = expires_at, service) when service in ["s3"] do
    amz_date = short_date(expires_at)
    %{secret_access_key: secret, region: region} = config

    ("AWS4" <> secret)
    |> sha256(amz_date)
    |> sha256(region)
    |> sha256(service)
    |> sha256("aws4_request")
  end

  defp short_date(%DateTime{} = expires_at) do
    expires_at
    |> amz_date()
    |> String.slice(0..7)
  end

  defp sha256(secret, msg), do: :crypto.mac(:hmac, :sha256, secret, msg)

  def get_file_url(key, bucket, expires_in) do
    [scheme, host] = System.get_env("PROJECT_URL_MEDIA") |> String.split("://")

    {:ok, url} =
      ExAws.Config.new(:s3, scheme: scheme <> "://", host: host, port: nil)
      |> ExAws.S3.presigned_url(:get, bucket, key, expires_in: expires_in)

    url
  end

  def put_object(key, bucket, file) do
    [scheme, host] = System.get_env("PROJECT_URL_MEDIA") |> String.split("://")

    config =
      if System.get_env("MIX_ENV") == "prod" do
        ExAws.Config.new(:s3, scheme: scheme <> "://", host: host, port: nil)
      else
        ExAws.Config.new(:s3, scheme: scheme <> "://", host: "localhost", port: 9000)
      end

    ExAws.S3.put_object(
      bucket,
      key,
      file
    )
    |> ExAws.request!(config)
  end

  # * The presign_upload function's job is to generate metadata
  # * returns a map of metadata and the socket unchanged
  # * It must return {:ok, metadata, socket}

  def presign_upload(entry, socket, key \\ "audio") do
    [scheme, host] = System.get_env("PROJECT_URL_MEDIA") |> String.split("://")

    config = ExAws.Config.new(:s3, scheme: scheme <> "://", host: host, port: nil)
    bucket = "invoicegenerator"
    key = "#{key}/#{entry.client_name}"

    # * Generates a presigned url for the object
    case ExAws.S3.presigned_url(config, :put, bucket, key,
           expires_in: 3600,
           query_params: [{"Content-Type", entry.client_type}]
         ) do
      {:ok, url} ->
        {:ok, %{uploader: "S3", key: key, url: url}, socket}

      {:error, reason} ->
        {:error, %{uploader: "S3", key: key, url: ~c""}, reason}
    end
  end
end
