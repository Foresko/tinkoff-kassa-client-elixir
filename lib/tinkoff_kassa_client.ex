defprotocol TinkoffKassaClient do
  @moduledoc false

  @type api_error() :: %{code: String.t(), message: String.t(), details: String.t() | nil}

  @type payment_status() ::
          :new
          | :form_showed
          | :authorizing
          | :three_domains_secure_checking
          | :three_domains_secure_checked
          | :authorized
          | :confirming
          | :confirmed
          | :reversing
          | :partial_reversed
          | :reversed
          | :refunding
          | :partial_refunded
          | :refunded
          | :canceled
          | :deadline_expired
          | :rejected
          | :auth_fail

  @type card_status() :: :active | :inactive | :deleted

  @type card_type() :: :widthdraw | :deposit

  @type receipt_taxation() :: :osn | :usn_income | :usn_income_outcome | :patent | :envd | :esn

  @type receipt_payments() :: %{
          optional(:cash) => integer(),
          required(:electronic) => integer(),
          optional(:cash) => integer(),
          optional(:advance_payment) => integer(),
          optional(:credit) => integer(),
          optional(:provision) => integer()
        }

  @type payment_method() ::
          :full_payment
          | :full_prepayment
          | :prepayment
          | :advance
          | :partial_payment
          | :credit
          | :credit_payment

  @type payment_object() ::
          :commodity
          | :excise
          | :job
          | :service
          | :gambling_bet
          | :gambling_prize
          | :lottery
          | :lottery_prize
          | :intellectual_activity
          | :payment
          | :agent_commission
          | :contribution
          | :property_rights
          | :unrealization
          | :tax_reduction
          | :trade_fee
          | :resort_tax
          | :pledge
          | :income_decrease
          | :ie_pension_insurance_without_payments
          | :ie_pension_insurance_with_payments
          | :ie_medical_insurance_without_payments
          | :ie_medical_insurance_with_payments
          | :social_insurance
          | :casino_chips
          | :agent_payment
          | :excisable_goods_without_marking_code
          | :excisable_goods_with_marking_code
          | :goods_without_marking_code
          | :goods_with_marking_code
          | :another

  @type tax() :: :none | :vat0 | :vat10 | :vat20 | :vat110 | :vat120

  @type receipt_item() :: %{
          required(:name) => String.t(),
          required(:price) => integer(),
          required(:quantity) => integer(),
          required(:amount) => integer(),
          required(:payment_method) => payment_method(),
          required(:payment_object) => payment_object(),
          required(:tax) => tax()
        }

  @type receipt() :: %{
          optional(:email) => String.t(),
          optional(:phone) => String.t(),
          required(:taxation) => receipt_taxation(),
          required(:items) => nonempty_list(receipt_item()),
          optional(:payments) => receipt_payments()
        }

  @type add_customer_params() :: %{
          optional(:ip) => String.t(),
          required(:customer_key) => String.t(),
          optional(:email) => String.t(),
          optional(:phone) => String.t()
        }

  @type add_customer_success_result() :: %{
          terminal_key: String.t(),
          customer_key: String.t()
        }

  @type remove_customer_params() :: %{
          optional(:ip) => String.t(),
          required(:customer_key) => String.t()
        }

  @type remove_customer_success_result() :: %{
          terminal_key: String.t(),
          customer_key: String.t()
        }

  @type get_customer_params() :: %{
          optional(:ip) => String.t(),
          required(:customer_key) => String.t()
        }

  @type get_customer_success_result() :: %{
          terminal_key: String.t(),
          customer_key: String.t(),
          email: String.t(),
          phone: String.t()
        }

  @type remove_card_params() :: %{
          optional(:ip) => String.t(),
          required(:customer_key) => String.t(),
          required(:card_id) => String.t()
        }

  @type remove_card_success_result() :: %{
          card_id: String.t(),
          pan: String.t(),
          status: card_status(),
          rebill_id: String.t(),
          card_types: [card_type()],
          exp_date: String.t()
        }

  @type get_card_list_params() :: %{
          optional(:ip) => String.t(),
          required(:customer_key) => String.t()
        }

  @type get_card_list_success_result() :: %{
          card_id: String.t(),
          pan: String.t(),
          status: card_status(),
          rebill_id: String.t(),
          card_types: [card_type()],
          exp_date: String.t()
        }

  @type init_params() :: %{
          optional(:ip) => String.t(),
          optional(:language) => :ru | :en,
          optional(:customer_key) => String.t(),
          required(:order_id) => String.t(),
          optional(:description) => String.t(),
          required(:amount) => non_neg_integer(),
          optional(:pay_type) => :O | :T,
          optional(:recurrent) => boolean(),
          optional(:redirect_due_date) => DateTime.t(),
          optional(:receipt) => receipt(),
          optional(:data) => map(),
          optional(:notification_url) => String.t(),
          optional(:success_url) => String.t(),
          optional(:fail_url) => String.t()
        }

  @type init_success_result() :: %{
          terminal_key: String.t(),
          payment_id: integer(),
          status: payment_status(),
          payment_url: String.t(),
          order_id: String.t(),
          amount: non_neg_integer()
        }

  @type charge_params() :: %{
          optional(:ip) => String.t(),
          required(:payment_id) => integer(),
          required(:rebill_id) => String.t(),
          optional(:send_email) => boolean(),
          optional(:info_email) => String.t()
        }

  @type charge_success_result() :: %{
          terminal_key: String.t(),
          payment_id: integer(),
          status: payment_status(),
          order_id: String.t(),
          amount: non_neg_integer()
        }

  @type cancel_params() :: %{
          optional(:ip) => String.t(),
          required(:payment_id) => integer(),
          optional(:amount) => non_neg_integer(),
          optional(:receipt) => receipt(),
          optional(:external_request_id) => String.t()
        }

  @type cancel_success_result() :: %{
          terminal_key: String.t(),
          payment_id: integer(),
          status: payment_status(),
          order_id: String.t(),
          original_amount: non_neg_integer(),
          new_amount: non_neg_integer()
        }

  @type get_qr_params() :: %{
          required(:payment_id) => integer(),
          optional(:data_type) => :PAYLOAD | :IMAGE
        }

  @type get_qr_success_result() :: %{
          terminal_key: String.t(),
          payment_id: integer(),
          order_id: String.t(),
          data: String.t()
        }

  @type sbp_pay_test_params() :: %{
          required(:payment_id) => integer(),
          optional(:is_deadline_expired) => boolean(),
          optional(:is_rejected) => boolean()
        }

  @type get_state_params() :: %{
          optional(:ip) => String.t(),
          required(:payment_id) => integer()
        }

  @type get_state_success_result() :: %{
          terminal_key: String.t(),
          payment_id: integer(),
          status: payment_status(),
          order_id: String.t(),
          amount: non_neg_integer()
        }

  @type check_order_params() :: %{required(:order_id) => String.t()}

  @type check_order_success_result() :: %{
          terminal_key: String.t(),
          order_id: String.t(),
          payments:
            list(%{
              payment_id: integer(),
              amount: non_neg_integer(),
              status: payment_status(),
              rrn: String.t() | nil,
              error_code: String.t(),
              message: String.t()
            })
        }

  @type resend_success_result() :: %{
          terminal_key: String.t(),
          count: integer()
        }

  @type verify_notification_params() :: %{optional(String.t()) => any()}

  @type verify_notification_success_result() :: %{
          terminal_key: String.t(),
          payment_id: integer(),
          status: payment_status(),
          order_id: String.t(),
          amount: non_neg_integer(),
          rebill_id: integer() | nil,
          card_id: integer() | nil,
          pan: String.t() | nil,
          exp_date: String.t() | nil,
          error_code: String.t() | nil
        }

  @type error() :: {:network_error, String.t()} | {:api_error, api_error()}

  @type result(success_result) :: {:ok, success_result} | {:error, error()}

  @spec terminal_key(t()) :: String.t()
  def terminal_key(client)

  @spec add_customer(
          t(),
          add_customer_params()
        ) :: result(add_customer_success_result())
  def add_customer(client, params)

  @spec remove_customer(
          t(),
          remove_customer_params()
        ) :: result(remove_customer_success_result())
  def remove_customer(client, params)

  @spec get_customer(
          t(),
          get_customer_params()
        ) :: result(get_customer_success_result())
  def get_customer(client, params)

  @spec remove_card(
          t(),
          remove_card_params()
        ) :: result(remove_card_success_result())
  def remove_card(client, params)

  @spec get_card_list(
          t(),
          get_card_list_params()
        ) :: result(get_card_list_success_result())
  def get_card_list(client, params)

  @spec init(
          t(),
          init_params()
        ) :: result(init_success_result())
  def init(client, params)

  @spec charge(
          t(),
          charge_params()
        ) :: result(charge_success_result())
  def charge(client, params)

  @spec cancel(
          t(),
          cancel_params()
        ) :: result(cancel_success_result())
  def cancel(client, params)

  @spec get_qr(
          t(),
          get_qr_params()
        ) :: result(get_qr_success_result())
  def get_qr(client, params)

  @spec sbp_pay_test(t(), sbp_pay_test_params()) :: result(nil)
  def sbp_pay_test(client, params)

  @spec get_state(
          t(),
          get_state_params()
        ) :: result(get_state_success_result())
  def get_state(client, params)

  @spec check_order(
          t(),
          check_order_params()
        ) :: result(check_order_success_result())
  def check_order(client, params)

  @spec resend(t()) :: result(resend_success_result())
  def resend(client)

  @spec verify_notification(
          t(),
          verify_notification_params()
        ) ::
          {:ok, verify_notification_success_result()} | :error
  def verify_notification(client, encoded_notification)
end
