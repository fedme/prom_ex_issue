defmodule PromExIssue.PromEx do
  use PromEx, otp_app: :prom_ex_issue

  @impl true
  def plugins do
    {:ok, agent} = Agent.start_link(fn -> 1 end)

    [{PromExIssue.CustomPromExPlugin, poll_rate: 2_000, debug_agent: agent}]
  end
end
