defmodule ZendeskApiTest do
  use ExUnit.Case
  doctest ZendeskApi

  test "greets the world" do
    assert ZendeskApi.hello() == :world
  end
end
