defmodule ZendeskSupportAPI do
  @moduledoc """
    Very limited Zendesk Support API

    ## Currently support endpoints
      - user
        - create or update
      - ticket
        - create
  """

  use HTTPoison.Base
  require Logger

  def process_request_url(route),
    do: "#{Application.get_env(:zendesk_support_api, :zendesk_domain)}" <> "/api/v2/" <> route

  def process_response_body(""), do: ""
  def process_response_body(body), do: Jason.decode!(body)

  def process_request_body(body), do: Jason.encode!(body)

  def process_request_headers(_headers) do
    [
      {"Authorization", "Basic #{auth_credentials()}"},
      {"Content-Type", "application/json"},
      {"Accepts", "application/json"}
    ]
  end

  defp auth_credentials do
    user = Application.get_env(:zendesk_support_api, :zendesk_user)
    token = Application.get_env(:zendesk_support_api, :zendesk_api_token)
    Base.encode64("#{user}/token:#{token}")
  end
end
