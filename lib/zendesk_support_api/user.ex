defmodule ZendeskSupportAPI.User do
  require Logger

  defstruct email: "",
            name: "",
            organization_id: -1,
            id: -1

  @type t() :: %__MODULE__{
          email: String.t(),
          name: String.t(),
          organization_id: integer(),
          id: integer()
        }

  @create_or_update_route "users/create_or_update.json"

  @spec create_or_update(map()) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def create_or_update(user),
    do: ZendeskSupportAPI.post(@create_or_update_route, %{user: user}, [])

  @spec add_tag_to_user(__MODULE__.t(), String.t()) :: {:ok, nil} | {:error, any()}
  def add_tag_to_user(%__MODULE__{email: email}, tag) do
    email
    |> get_user_id()
    |> add_tag(tag)
  end

  @spec remove_tag_from_user(__MODULE__.t(), String.t()) :: :ok
  def remove_tag_from_user(%__MODULE__{email: email}, tag) do
    email
    |> get_user_id()
    |> delete_tag(tag)
    |> case do
      {:ok, nil} -> :ok
      {:error, error} -> Logger.error(error)
    end
  end

  @spec ensure_user_exists!(map()) :: __MODULE__.t()
  def ensure_user_exists!(user_details) do
    user_details.email
    |> get_user()
    |> ensure_created(user_details)
    |> parse_user!()
  end

  defp ensure_created({:ok, user}, _), do: user

  defp ensure_created({:error, _}, %{email: email, first_name: fname, last_name: lname}) do
    %{email: email, name: "#{fname} #{lname}"}
    |> create_or_update()
    |> parse_body()
  end

  defp parse_user!(%{"user" => user}), do: parse_user!(user)

  defp parse_user!(%{"id" => id, "email" => email, "organization_id" => org_id, "name" => name}) do
    %__MODULE__{
      name: name,
      organization_id: org_id,
      email: email,
      id: id
    }
  end

  defp parse_user!(response),
    do: raise("Unexpected response from Zendesk server. Response: #{inspect(response)}")

  defp get_user(email) do
    "users/search?query=#{email}"
    |> ZendeskSupportAPI.get()
    |> parse_body()
    |> Map.get("users")
    |> handle_list(email)
  end

  defp get_user_id(nil), do: {:error, "No email"}

  defp get_user_id(email) do
    email
    |> get_user()
    |> get_id_from_user()
  end

  defp get_id_from_user({:error, error}), do: {:error, error}
  defp get_id_from_user({:ok, user}), do: {:ok, Map.get(user, "id")}

  defp handle_list(list, email) when list == nil or list == [],
    do: {:error, "Couldn't find Zendesk user with provided email address: #{email}"}

  defp handle_list([user | _], _), do: {:ok, user}

  defp add_tag({:error, error}, _), do: {:error, error}

  defp add_tag({:ok, user_id}, tag) do
    ZendeskSupportAPI.put("users/#{user_id}/tags?tags=[\"#{tag}\"]")
    {:ok, nil}
  end

  defp delete_tag({:error, error}, _), do: {:error, error}

  defp delete_tag({:ok, user_id}, tag) do
    ZendeskSupportAPI.delete("users/#{user_id}/tags?tags=[\"#{tag}\"]")
    {:ok, nil}
  end

  defp parse_body({:ok, response}), do: Map.get(response, :body)
  defp parse_body({:error, _}), do: %{}
end
