defmodule InvoiceGenerator.Helpers do
  alias InvoiceGenerator.Profile

  def get_profile_url(user_id) do
    case get_user(user_id) do
      nil ->
        ""

      user ->
        base_url = "http://127.0.0.1:9000/invoicegenerator/photo/"

        user_profile_picture_url = base_url <> user.picture.original_filename

        user_profile_picture_url
    end
  end

  @doc """
  Gets a user's profile
  """
  def get_user(user_id) do
    Profile.get_user_profile_by_user_id(user_id)
  end

  def countries do
    [
      "Afghanistan",
      "Albania",
      "Algeria",
      "Andorra",
      "Angola",
      "Antigua and Barbuda",
      "Argentina",
      "Armenia",
      "Australia",
      "Austria",
      "Azerbaijan",
      "Bahamas",
      "Bahrain",
      "Bangladesh",
      "Barbados",
      "Belarus",
      "Belgium",
      "Belize",
      "Benin",
      "Bhutan",
      "Bolivia",
      "Bosnia and Herzegovina",
      "Botswana",
      "Brazil",
      "Brunei",
      "Bulgaria",
      "Burkina Faso",
      "Burundi",
      "Cabo Verde",
      "Cambodia",
      "Cameroon",
      "Canada",
      "Central African Republic",
      "Chad",
      "Chile",
      "China",
      "Colombia",
      "Comoros",
      "Congo (Congo-Brazzaville)",
      "Costa Rica",
      "Croatia",
      "Cuba",
      "Cyprus",
      "Czechia",
      "Democratic Republic of the Congo",
      "Denmark",
      "Djibouti",
      "Dominica",
      "Dominican Republic",
      "Ecuador",
      "Egypt",
      "El Salvador",
      "Equatorial Guinea",
      "Eritrea",
      "Estonia",
      "Eswatini",
      "Ethiopia",
      "Fiji",
      "Finland",
      "France",
      "Gabon",
      "Gambia",
      "Georgia",
      "Germany",
      "Ghana",
      "Greece",
      "Grenada",
      "Guatemala",
      "Guinea",
      "Guinea-Bissau",
      "Guyana",
      "Haiti",
      "Honduras",
      "Hungary",
      "Iceland",
      "India",
      "Indonesia",
      "Iran",
      "Iraq",
      "Ireland",
      "Israel",
      "Italy",
      "Jamaica",
      "Japan",
      "Jordan",
      "Kazakhstan",
      "Kenya",
      "Kiribati",
      "Kuwait",
      "Kyrgyzstan",
      "Laos",
      "Latvia",
      "Lebanon",
      "Lesotho",
      "Liberia",
      "Libya",
      "Liechtenstein",
      "Lithuania",
      "Luxembourg",
      "Madagascar",
      "Malawi",
      "Malaysia",
      "Maldives",
      "Mali",
      "Malta",
      "Marshall Islands",
      "Mauritania",
      "Mauritius",
      "Mexico",
      "Micronesia",
      "Moldova",
      "Monaco",
      "Mongolia",
      "Montenegro",
      "Morocco",
      "Mozambique",
      "Myanmar (Burma)",
      "Namibia",
      "Nauru",
      "Nepal",
      "Netherlands",
      "New Zealand",
      "Nicaragua",
      "Niger",
      "Nigeria",
      "North Korea",
      "North Macedonia",
      "Norway",
      "Oman",
      "Pakistan",
      "Palau",
      "Palestine",
      "Panama",
      "Papua New Guinea",
      "Paraguay",
      "Peru",
      "Philippines",
      "Poland",
      "Portugal",
      "Qatar",
      "Romania",
      "Russia",
      "Rwanda",
      "Saint Kitts and Nevis",
      "Saint Lucia",
      "Saint Vincent and the Grenadines",
      "Samoa",
      "San Marino",
      "Sao Tome and Principe",
      "Saudi Arabia",
      "Senegal",
      "Serbia",
      "Seychelles",
      "Sierra Leone",
      "Singapore",
      "Slovakia",
      "Slovenia",
      "Solomon Islands",
      "Somalia",
      "South Africa",
      "South Korea",
      "South Sudan",
      "Spain",
      "Sri Lanka",
      "Sudan",
      "Suriname",
      "Sweden",
      "Switzerland",
      "Syria",
      "Tajikistan",
      "Tanzania",
      "Thailand",
      "Timor-Leste",
      "Togo",
      "Tonga",
      "Trinidad and Tobago",
      "Tunisia",
      "Turkey",
      "Turkmenistan",
      "Tuvalu",
      "Uganda",
      "Ukraine",
      "United Arab Emirates",
      "United Kingdom",
      "United States",
      "Uruguay",
      "Uzbekistan",
      "Vanuatu",
      "Vatican City",
      "Venezuela",
      "Vietnam",
      "Yemen",
      "Zambia",
      "Zimbabwe"
    ]
  end

  def payment_terms() do
    [
      %{name: "Net 30 Days"},
      %{name: "Net 14 Days"},
      %{name: "Net 7 Days"},
      %{name: "Net 1 Day"}
    ]
  end

  def string_mappings_of_days do
    %{"Net 30 Days" => 30, "Net 14 Days" => 14, "Net 7 Days" => 7, "Net 1 Day" => 1}
  end

  def get_map_of_errors(errors) do
    # removes the password key from the keyword list
    messages =
      Enum.reduce(errors, [], fn {_key, value}, acc ->
        [value | acc]
      end)

    # converts the keyword items into a map with atom keys

    result =
      Enum.map(messages, fn {x, y} -> {String.to_atom(x), y} end)
      |> Enum.into(%{})

    result
  end

  def initial_errors() do
    %{
      length: "errors",
      uppercase: "errors",
      number: "errors",
      special: "errors"
    }
  end

  def get_totals(params, count) do
    # count = 2

    # params = %{
    #   "product_1_name" => "orange",
    #   "product_1_price" => "23",
    #   "product_1_quantity" => "34",
    #   "product_1_total" => "",
    #   "product_2_name" => "mango",
    #   "product_2_price" => "67",
    #   "product_2_quantity" => "12",
    #   "product_2_total" => ""
    # }

    list = Enum.to_list(1..count)

    # * Now that we have the list of numbers of the products
    # * we can invoke this function for all the numbers in the list

    list_of_maps_of_products =
      Enum.map(list, fn x ->
        get_total_helper(params, x)
      end)

    final_map_containing_total = merge_individual_maps_to_one(list_of_maps_of_products)

    final_map_containing_total = map_with_string_keys(final_map_containing_total)
    final_map_containing_total
  end

  def get_total_helper(params, count) do
    price = params["product_#{count}_price"]
    price = Integer.parse(price)
    quantity = params["product_#{count}_quantity"]
    quantity = Integer.parse(quantity)

    # * This code here adds a total to each field
    # * in the first iteration to product 1 and in the second iteration to product 2
    # * params is the result

    params =
      case price == :error do
        true ->
          params =
            Map.merge(params, %{"product_#{count}_total" => "quantity and price must be numbers"})

          params

        false ->
          case quantity == :error do
            true ->
              params =
                Map.merge(params, %{
                  "product_#{count}_total" => "quantity and price must be numbers"
                })

              params

            false ->
              total = elem(price, 0) * elem(quantity, 0)

              params = Map.merge(params, %{"product_#{count}_total" => "#{total}"})

              params
          end
      end

    # * Using the unique prefix for fields e.g product_1 this code here
    # * groups each map of a product as its own map
    individual_map_for_product =
      Enum.reduce(params, %{}, fn {key, value}, accumulator_map ->
        case String.starts_with?(key, "product_#{count}") do
          true ->
            Map.put(accumulator_map, key, value)

          false ->
            accumulator_map
        end
      end)

    # * this code transforms our map from having string keys to having atom keys
    # * in preparation for the next step
    individual_map_with_atom_keys =
      Enum.map(individual_map_for_product, fn {x, y} -> {String.to_atom(x), y} end)
      |> Enum.into(%{})

    individual_map_with_atom_keys
  end

  def merge_individual_maps_to_one(list_of_maps) do
    merged_map =
      Enum.reduce(list_of_maps, %{}, fn map, empty_map ->
        Map.merge(empty_map, map)
      end)

    merged_map
  end

  defp map_with_string_keys(map) do
    string_keys_map = Map.new(map, fn {key, value} -> {"#{key}", value} end)
    string_keys_map
  end

  def get_list_of_params(params, count) do
    # params = %{
    #   "product_1_name" => "mango",
    #   "product_1_price" => "54",
    #   "product_1_quantity" => "34",
    #   "product_2_name" => "colgate",
    #   "product_2_price" => "56",
    #   "product_2_quantity" => "43",
    #   "product_3_name" => "apple",
    #   "product_3_price" => "23",
    #   "product_3_quantity" => "19"
    # }

    # count = 2

    list = Enum.to_list(1..count)

    Enum.map(list, fn x ->
      get_map_of_product(params, x)
    end)
  end

  def get_map_of_product(params, count) do
    # * Here we return a list of tuples with each count iteration
    list_of_tuples =
      Enum.reduce(params, [], fn {key, value}, list ->
        case String.starts_with?(key, "product_#{count}") do
          true ->
            prefix = "product_#{count}_"
            key = String.replace_prefix(key, prefix, "")
            # We need to include the count as part of our return value
            [{key, value} | list]

          false ->
            list
        end
      end)

    # * converts the list of tuples into a map with atom keys

    map_of_product =
      Enum.map(list_of_tuples, fn {x, y} -> {String.to_atom(x), y} end)
      |> Enum.into(%{})

    # * adds an error field to detect missing details

    map_of_product =
      case Enum.find(map_of_product, fn {_key, value} ->
             value == "" or value == "quantity and price must be numbers"
           end) do
        nil ->
          map_of_product = Map.put(map_of_product, :errors, false)
          map_of_product

        _ ->
          map_of_product = Map.put(map_of_product, :errors, true)
          map_of_product
      end

    map_of_product
  end
end
