defmodule PromExIssue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PromExIssueWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:prom_ex_issue, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PromExIssue.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PromExIssue.Finch},
      # Start a worker by calling: PromExIssue.Worker.start_link(arg)
      # {PromExIssue.Worker, arg},
      # Start to serve requests, typically the last entry
      PromExIssueWeb.Endpoint,
      # PromEx should be started after the Endpoint, to avoid unnecessary error messages
      PromExIssue.PromEx
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PromExIssue.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PromExIssueWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
