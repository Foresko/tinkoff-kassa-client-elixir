defmodule DefaultTinkoffKassaClient do
  @moduledoc false

  @enforce_keys [:terminal_key, :password]

  defstruct [
    :terminal_key,
    :password,
    notification_url: nil,
    success_url: nil,
    fail_url: nil
  ]

  @type t() :: %__MODULE__{
          terminal_key: String.t(),
          password: String.t(),
          notification_url: String.t() | nil,
          success_url: String.t() | nil,
          fail_url: String.t() | nil
        }
end

defimpl TinkoffKassaClient, for: DefaultTinkoffKassaClient do
  @moduledoc false

  nowarn_functions =
    for {name, arities} <- [
          {:get, [1, 2, 3]},
          {:get!, [1, 2, 3]},
          {:put, [1, 2, 3]},
          {:put!, [1, 2, 3]},
          {:delete, [1, 2, 3]},
          {:delete!, [1, 2, 3]},
          {:options, [1, 2, 3]},
          {:options!, [1, 2, 3]},
          {:head, [1, 2, 3]},
          {:head!, [1, 2, 3]},
          {:request, [2]},
          {:request!, [2]}
        ],
        arity <- arities do
      {name, arity}
    end

  @dialyzer {:nowarn_function, nowarn_functions}

  use HTTPoison.Base

  @api_endpoint "https://securepay.tinkoff.ru/v2"

  @impl HTTPoison.Base
  def process_url(url) do
    @api_endpoint <> url
  end

  @impl HTTPoison.Base
  def process_request_body(body)

  def process_request_body(body) when is_map(body) do
    token = calculate_request_token(body)

    body
    |> Map.delete("Password")
    |> Map.put("Token", token)
    |> Jason.encode!()
  end

  def process_request_body("" = body) do
    body
  end

  @impl HTTPoison.Base
  def process_request_headers(headers) do
    [{"content-type", "application/json"} | headers]
  end

  @impl HTTPoison.Base
  def process_response_body(body) do
    Jason.decode!(body)
  end

  @impl TinkoffKassaClient
  @spec terminal_key(DefaultTinkoffKassaClient.t()) :: String.t()
  def terminal_key(%DefaultTinkoffKassaClient{} = client) do
    client.terminal_key
  end

  @impl TinkoffKassaClient
  @spec add_customer(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.add_customer_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.add_customer_success_result())
  def add_customer(client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:ip, value} -> {"IP", value}
          {:customer_key, value} -> {"CustomerKey", value}
          {:email, value} -> {"Email", value}
          {:phone, value} -> {"Phone", value}
        end
      )

    case post("/AddCustomer", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result = %{
          terminal_key: response.body["TerminalKey"],
          customer_key: response.body["CustomerKey"]
        }

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec remove_customer(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.remove_customer_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.remove_customer_success_result())
  def remove_customer(client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:ip, value} -> {"IP", value}
          {:customer_key, value} -> {"CustomerKey", value}
        end
      )

    case post("/RemoveCustomer", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result = %{
          terminal_key: response.body["TerminalKey"],
          customer_key: response.body["CustomerKey"]
        }

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec get_customer(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.get_customer_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.get_customer_success_result())
  def get_customer(client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:ip, value} -> {"IP", value}
          {:customer_key, value} -> {"CustomerKey", value}
        end
      )

    case post("/GetCustomer", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result = %{
          terminal_key: response.body["TerminalKey"],
          customer_key: response.body["CustomerKey"],
          email: response.body["Email"],
          phone: response.body["Phone"]
        }

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec remove_card(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.remove_card_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.remove_card_success_result())
  def remove_card(client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:ip, value} -> {"IP", value}
          {:customer_key, value} -> {"CustomerKey", value}
          {:card_id, value} -> {"CardId", value}
        end
      )

    case post("/RemoveCard", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result =
          Enum.map(
            response,
            fn card ->
              %{
                card_id: card["CardId"],
                pan: card["Pan"],
                status: decode_card_status(card["Status"]),
                rebill_id: card["RebillId"],
                card_types: decode_card_types(card["CardType"]),
                exp_date: card["ExpDate"]
              }
            end
          )

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec get_card_list(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.get_card_list_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.get_card_list_success_result())
  def get_card_list(client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:ip, value} -> {"IP", value}
          {:customer_key, value} -> {"CustomerKey", value}
        end
      )

    case post("/GetCardList", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response}} when is_list(response) ->
        success_result =
          Enum.map(
            response,
            fn card ->
              %{
                card_id: card["CardId"],
                pan: card["Pan"],
                status: decode_card_status(card["Status"]),
                rebill_id: card["RebillId"],
                card_types: decode_card_types(card["CardType"]),
                exp_date: card["ExpDate"]
              }
            end
          )

        {:ok, success_result}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec init(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.init_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.init_success_result())
  def init(%DefaultTinkoffKassaClient{} = client, params) do
    body =
      client
      |> payment_default_params()
      |> Map.merge(params)
      |> Enum.into(
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:ip, value} ->
            {"IP", value}

          {:language, value} ->
            {"Language", value}

          {:customer_key, value} ->
            {"CustomerKey", value}

          {:order_id, value} ->
            {"OrderId", value}

          {:description, value} ->
            {"Description", value}

          {:amount, value} ->
            {"Amount", value}

          {:pay_type, value} ->
            {"PayType", value}

          {:recurrent, value} ->
            value =
              case value do
                true -> "Y"
                false -> "N"
              end

            {"Recurrent", value}

          {:redirect_due_date, value} ->
            {"RedirectDueDate", value |> DateTime.to_iso8601() |> String.trim()}

          {:receipt, value} ->
            {"Receipt", receipt_to_api_type(value)}

          {:data, value} ->
            {"DATA", value}

          {:notification_url, value} ->
            {"NotificationURL", value}

          {:success_url, value} ->
            {"SuccessURL", value}

          {:fail_url, value} ->
            {"FailURL", value}
        end
      )

    case post("/Init", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result = %{
          terminal_key: response.body["TerminalKey"],
          payment_id: response.body["PaymentId"] |> to_string() |> String.to_integer(),
          status: decode_payment_status(response.body["Status"]),
          payment_url: response.body["PaymentURL"],
          order_id: response.body["OrderId"],
          amount: response.body["Amount"]
        }

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec charge(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.charge_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.charge_success_result())
  def charge(%DefaultTinkoffKassaClient{} = client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:ip, value} ->
            {"IP", value}

          {:payment_id, value} ->
            {"PaymentId", value}

          {:rebill_id, value} ->
            {"RebillId", value}

          {:send_email, value} ->
            {"SendEmail", value}

          {:info_email, value} ->
            {"InfoEmail", value}
        end
      )

    case post("/Charge", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result = %{
          terminal_key: response.body["TerminalKey"],
          payment_id: response.body["PaymentId"] |> to_string() |> String.to_integer(),
          status: decode_payment_status(response.body["Status"]),
          payment_url: response.body["PaymentURL"],
          order_id: response.body["OrderId"],
          amount: response.body["Amount"]
        }

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec cancel(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.cancel_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.cancel_success_result())
  def cancel(%DefaultTinkoffKassaClient{} = client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:ip, value} ->
            {"IP", value}

          {:payment_id, value} ->
            {"PaymentId", value}

          {:amount, value} ->
            {"Amount", value}

          {:receipt, value} ->
            {"Receipt", receipt_to_api_type(value)}

          {:external_request_id, value} ->
            {"ExternalRequestId", value}
        end
      )

    case post("/Cancel", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result = %{
          terminal_key: response.body["TerminalKey"],
          payment_id: to_string(response.body["PaymentId"] |> to_string() |> String.to_integer()),
          status: decode_payment_status(response.body["Status"]),
          order_id: response.body["OrderId"],
          original_amount: response.body["OriginalAmount"],
          new_amount: response.body["NewAmount"]
        }

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:ok, %HTTPoison.Response{status_code: 400, body: %{}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec get_qr(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.get_qr_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.get_qr_success_result())
  def get_qr(%DefaultTinkoffKassaClient{} = client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:payment_id, value} -> {"PaymentId", value}
          {:data_type, value} -> {"DataType", value}
        end
      )

    case post("/GetQr", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result = %{
          terminal_key: response.body["TerminalKey"],
          payment_id: to_string(response.body["PaymentId"] |> to_string() |> String.to_integer()),
          order_id: response.body["OrderId"],
          data: response.body["Data"]
        }

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec sbp_pay_test(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.sbp_pay_test_params()
        ) ::
          TinkoffKassaClient.result(nil)
  def sbp_pay_test(%DefaultTinkoffKassaClient{} = client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:payment_id, value} -> {"PaymentId", value}
          {:is_deadline_expired, value} -> {"IsDeadlineExpired", value}
          {:is_rejected, value} -> {"IsRejected", value}
        end
      )

    case post("/SbpPayTest", body, [], timeout: 10_000_000, recv_timeout: 10_000_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = _response} ->
        {:ok, nil}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec get_state(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.get_state_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.get_state_success_result())
  def get_state(%DefaultTinkoffKassaClient{} = client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:ip, value} -> {"IP", value}
          {:payment_id, value} -> {"PaymentId", value}
        end
      )

    case post("/GetState", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result = %{
          terminal_key: response.body["TerminalKey"],
          payment_id: to_string(response.body["PaymentId"] |> to_string() |> String.to_integer()),
          status: decode_payment_status(response.body["Status"]),
          order_id: response.body["OrderId"],
          amount: response.body["Amount"]
        }

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec check_order(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.check_order_params()
        ) ::
          TinkoffKassaClient.result(TinkoffKassaClient.check_order_success_result())
  def check_order(%DefaultTinkoffKassaClient{} = client, params) do
    body =
      Enum.into(
        params,
        %{"TerminalKey" => client.terminal_key, "Password" => client.password},
        fn
          {:order_id, value} -> {"OrderId", value}
        end
      )

    case post("/CheckOrder", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result = %{
          terminal_key: response.body["TerminalKey"],
          order_id: response.body["OrderId"],
          payments:
            Enum.map(response.body["Payments"], fn payment ->
              %{
                payment_id: payment["PaymentId"] |> to_string() |> String.to_integer(),
                amount: payment["Amount"],
                status: decode_payment_status(payment["Status"]),
                rrn: payment["RRN"],
                error_code: payment["ErrorCode"],
                message: payment["Message"]
              }
            end)
        }

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec resend(DefaultTinkoffKassaClient.t()) ::
          TinkoffKassaClient.result(TinkoffKassaClient.resend_success_result())
  def resend(client) do
    body = %{"TerminalKey" => client.terminal_key, "Password" => client.password}

    case post("/Resend", body) do
      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => true}} = response} ->
        success_result = %{
          terminal_key: response.body["TerminalKey"],
          count: response.body["Count"]
        }

        {:ok, success_result}

      {:ok, %HTTPoison.Response{status_code: 200, body: %{"Success" => false}} = response} ->
        api_error = %{
          code: response.body["ErrorCode"],
          message: response.body["Message"],
          details: response.body["Details"]
        }

        {:error, {:api_error, api_error}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:network_error, error.reason}}
    end
  end

  @impl TinkoffKassaClient
  @spec verify_notification(
          DefaultTinkoffKassaClient.t(),
          TinkoffKassaClient.verify_notification_params()
        ) ::
          {:ok, TinkoffKassaClient.verify_notification_success_result()} | :error
  def verify_notification(%DefaultTinkoffKassaClient{} = client, encoded_notification) do
    expected_token =
      encoded_notification
      |> Map.drop(["TerminalKey", "Token"])
      |> Map.put("TerminalKey", client.terminal_key)
      |> Map.put("Password", client.password)
      |> calculate_request_token()

    cond do
      encoded_notification["Token"] == expected_token ->
        notification = %{
          terminal_key: to_string(encoded_notification["TerminalKey"]),
          payment_id: encoded_notification["PaymentId"] |> to_string() |> String.to_integer(),
          status: decode_payment_status(encoded_notification["Status"]),
          order_id: encoded_notification["OrderId"],
          amount: encoded_notification["Amount"],
          rebill_id: encoded_notification["RebillId"],
          card_id: encoded_notification["CardId"],
          pan: encoded_notification["Pan"],
          exp_date: encoded_notification["ExpDate"],
          error_code: encoded_notification["ErrorCode"]
        }

        {:ok, notification}

      true ->
        :error
    end
  end

  defp receipt_to_api_type(receipt) do
    Enum.into(
      receipt,
      %{},
      fn
        {:email, value} -> {"Email", value}
        {:phone, value} -> {"Phone", value}
        {:taxation, value} -> {"Taxation", value}
        {:items, value} -> {"Items", Enum.map(value, &receipt_item_to_api_type/1)}
      end
    )
  end

  defp receipt_item_to_api_type(receipt_item) do
    Enum.into(
      receipt_item,
      %{},
      fn
        {:name, value} -> {"Name", value}
        {:price, value} -> {"Price", value}
        {:quantity, value} -> {"Quantity", value}
        {:amount, value} -> {"Amount", value}
        {:payment_method, value} -> {"PaymentMethod", value}
        {:payment_object, value} -> {"PaymentObject", value}
        {:tax, value} -> {"Tax", value}
      end
    )
  end

  defp payment_default_params(client) do
    client
    |> Map.from_struct()
    |> Map.take([:notification_url, :success_url, :fail_url])
    |> Enum.filter(fn {_key, value} -> value != nil end)
    |> Map.new()
  end

  defp calculate_request_token(request_body) do
    request_body
    |> Map.to_list()
    |> List.keysort(0)
    |> Stream.map(fn {_key, value} -> value end)
    |> Stream.reject(&is_map/1)
    |> Stream.reject(&is_list/1)
    |> Enum.join()
    |> then(&:crypto.hash(:sha256, &1))
    |> Base.encode16(case: :lower)
  end

  defp decode_payment_status(term) do
    case term do
      "NEW" -> :new
      "FORM_SHOWED" -> :form_showed
      "3DS_CHECKING" -> :three_domains_secure_checking
      "3DS_CHECKED" -> :three_domains_secure_checked
      "AUTHORIZED" -> :authorized
      "CONFIRMING" -> :confirming
      "CONFIRMED" -> :confirmed
      "REVERSING" -> :reversing
      "PARTIAL_REVERSED" -> :partial_reversed
      "REVERSED" -> :reversed
      "REFUNDING" -> :refunding
      "PARTIAL_REFUNDED" -> :partial_refunded
      "REFUNDED" -> :refunded
      "CANCELED" -> :canceled
      "DEADLINE_EXPIRED" -> :deadline_expired
      "REJECTED" -> :rejected
      "AUTH_FAIL" -> :auth_fail
    end
  end

  defp decode_card_status(term) do
    case term do
      "A" -> :active
      "I" -> :inactive
      "D" -> :deleted
    end
  end

  defp decode_card_types(term) do
    case term do
      0 -> [:widthdraw]
      1 -> [:deposit]
      2 -> [:widthdraw, :deposit]
    end
  end
end
