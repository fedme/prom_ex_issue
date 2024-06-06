defmodule PromExIssue.CustomPromExPlugin do
  use PromEx.Plugin

  @default_poll_rate 5_000
  @ping_event_name [:custom, :prom_ex, :plugin, :ping]

  @impl true
  def polling_metrics(opts) do
    poll_rate = Keyword.get(opts, :poll_rate, @default_poll_rate)
    debug_agent = opts[:debug_agent]

    Polling.build(
      :custom_prom_ex_plugin_ping_metrics,
      poll_rate,
      {__MODULE__, :execute_ping_metrics, [debug_agent]},
      [
        last_value(
          [:custom, :prom_ex, :plugin, :metrics],
          event_name: @ping_event_name,
          measurement: :count,
          description: "Ping for debugging",
          tags: [:state]
        )
      ]
    )
  end

  def execute_ping_metrics(debug_agent) do
    invocation_counter = Agent.get(debug_agent, & &1)

    IO.puts("""

    ######################################################################
    MFA execute_ping_metrics called for the #{invocation_counter} time.
    ######################################################################

    """)

    Agent.update(debug_agent, fn counter -> counter + 1 end)

    # Error case 1
    # if invocation_counter < 10 do
    #   raise "Something is not initialized correctly, I can't return the metrics!"
    # end

    # Error case 2
    if invocation_counter > 5 and invocation_counter < 10 do
      raise "Something is not working correctly, I can't return the metrics right now!"
    end

    # Send a debug ping event
    :telemetry.execute(@ping_event_name, %{count: :rand.uniform(101) - 1}, %{state: "ping"})
  end
end
