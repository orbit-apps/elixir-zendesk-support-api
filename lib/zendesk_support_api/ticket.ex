defmodule ZendeskSupportAPI.Ticket do
  @create_route "tickets.json"

  @spec create(map()) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def create(ticket), do: ZendeskSupportAPI.post(@create_route, %{ticket: ticket}, [])
end
