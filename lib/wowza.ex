defmodule Wowza do
  @moduledoc """
  Wowza REST API wrapper
  """

  use HTTPoison.Base

  @api_version "v1.3/"
  @base_url "https://api.cloud.wowza.com/api/"
  @ok_statuses [200, 201, 202, 204]

  def process_request_url(url) when is_binary(url),
    do: @base_url |> URI.merge(@api_version) |> URI.merge(url) |> to_string

  def process_response_body(""), do: nil
  def process_response_body(body), do: Jason.decode!(body)
  def process_request_body(body), do: Jason.encode!(body)

  def create_live_stream(params, access_key, api_key) when is_map(params) do
    with {:ok, response} <-
           __MODULE__.post(
             "live_streams",
             %{live_stream: params},
             headers(access_key, api_key)
           ) do
      process_body(response)
    end
  end

  def start_live_stream(id, access_key, api_key) when is_binary(id) do
    with {:ok, response} <-
           __MODULE__.put("live_streams/#{id}/start", nil, headers(access_key, api_key)) do
      process_body(response)
    end
  end

  def stop_live_stream(id, access_key, api_key) when is_binary(id) do
    with {:ok, response} <-
           __MODULE__.put("live_streams/#{id}/stop", nil, headers(access_key, api_key)) do
      process_body(response)
    end
  end

  def delete_live_stream(id, access_key, api_key) when is_binary(id) do
    with {:ok, %{status_code: 204}} <-
           __MODULE__.delete("live_streams/" <> id, headers(access_key, api_key)) do
      {:ok, nil}
    else
      {:ok, response} -> process_body(response)
      err -> err
    end
  end

  def get_live_stream(id, access_key, api_key) when is_binary(id) do
    with {:ok, response} <- __MODULE__.get("live_streams/" <> id, headers(access_key, api_key)) do
      process_body(response)
    end
  end

  defp process_body(%{status_code: status_code, body: %{"live_stream" => live_stream}})
       when status_code in @ok_statuses,
       do: {:ok, live_stream}

  defp process_body(%{status_code: status_code, body: body})
       when status_code in @ok_statuses,
       do: {:ok, body}

  defp process_body(%{body: %{"meta" => %{"title" => title, "message" => message}}}),
    do: {:error, {title, message}}

  defp headers(access_key, api_key),
    do: ["wsc-access-key": access_key, "wsc-api-key": api_key, "content-type": "application/json"]
end
