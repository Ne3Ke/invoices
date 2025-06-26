# InvoiceGenerator👀

This is a Phoenix application with a PostgreSQL database

## Requirements

- Elixir >= 1.17
- PostgreSQL 15
- Minio - download from [MinIO for MacOS](https://min.io/docs/minio/macos/index.html)

## Getting started

- Run `mix setup` to install and setup dependencies

- Create a **.env** file in the root of the project following the **.env.example** example fields

- If using MacOS, Run your **Local MinIO Server** from the CMD

```zsh
minio server ~/home/shared/
```

- You will need to register to [Brevo](https://app.brevo.com/) to get an **API KEY** to send emails

- Change the values of **S3_ACCESS_KEY_ID**, **S3_SECRET_ACCESS_KEY**,**S3_BUCKET** and **BREVO_API_KEY** to match your configuration.

- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
