defmodule TinkoffKassaClient.TestCaseHelpers do
  @moduledoc false

  def complete_case_1(client, attempt \\ 1) do
    {:ok, data} =
      TinkoffKassaClient.init(client, %{order_id: "TEST_CASE.1.#{attempt}", amount: 100_00})

    IO.puts("Ссылка на оплату: #{data.payment_url}. Данные карты 4300 0000 0000 0777, 12/30, 111")
    :ok
  end

  def complete_case_2(client, attempt \\ 1) do
    {:ok, data} =
      TinkoffKassaClient.init(client, %{order_id: "TEST_CASE.2.#{attempt}", amount: 100_00})

    IO.puts("Ссылка на оплату: #{data.payment_url}. Данные карты 5000 0000 0000 0009, 12/30, 111")
    :ok
  end

  def complete_case_3(client, attempt \\ 1) do
    {:ok, data} =
      TinkoffKassaClient.init(client, %{order_id: "TEST_CASE.3.#{attempt}", amount: 100_00})

    IO.puts("Ссылка на оплату: #{data.payment_url}. Данные карты 4000 0000 0000 0119, 12/30, 111")

    with :ok <- await_payment_confirmation(client, data.payment_id) do
      TinkoffKassaClient.cancel(client, %{payment_id: data.payment_id})
      :ok
    else
      _ ->
        :error
    end
  end

  def complete_case_7(client, attempt \\ 1) do
    {:ok, data} =
      TinkoffKassaClient.init(client, %{
        order_id: "TEST_CASE.7.#{attempt}",
        amount: 100_00,
        receipt: %{
          email: "developer@foresko.com",
          taxation: :usn_income_outcome,
          items: [
            %{
              name: "Тестовая покупка",
              price: 100_00,
              quantity: 1,
              amount: 100_00,
              payment_method: :full_payment,
              payment_object: :commodity,
              tax: :none
            }
          ]
        }
      })

    IO.puts("Ссылка на оплату: #{data.payment_url}. Данные карты 4000 0000 0000 0101, 12/30, 111")
    :ok
  end

  def complete_case_8(client, attempt \\ 1) do
    {:ok, data} =
      TinkoffKassaClient.init(
        client,
        %{
          order_id: "TEST_CASE.8.#{attempt}",
          amount: 100_00,
          receipt: %{
            email: "developer@foresko.com",
            taxation: :usn_income_outcome,
            items: [
              %{
                name: "Тестовая покупка",
                price: 100_00,
                quantity: 1,
                amount: 100_00,
                payment_method: :full_payment,
                payment_object: :commodity,
                tax: :none
              }
            ]
          }
        }
      )

    IO.puts("Ссылка на оплату: #{data.payment_url}. Данные карты 5000 0000 0000 0108, 12/30, 111")

    with :ok <- await_payment_confirmation(client, data.payment_id) do
      TinkoffKassaClient.cancel(client, %{payment_id: data.payment_id})
      :ok
    else
      _ ->
        :error
    end
  end

  defp await_payment_confirmation(client, payment_id) do
    Process.sleep(5_000)

    case TinkoffKassaClient.get_state(client, %{payment_id: payment_id}) do
      {:ok, %{status: :confirmed}} ->
        :ok

      {:ok, _} ->
        await_payment_confirmation(client, payment_id)

      {:error, error} ->
        IO.puts("Не удалось получить статус платежа: #{inspect(error)}")
        :error
    end
  end
end
