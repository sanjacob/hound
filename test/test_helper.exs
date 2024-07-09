Application.start :inets

driver = System.get_env("WEBDRIVER")

if driver == "geckodriver" do
  IO.puts "Running the test suite is not supported with this driver"
  exit(:shutdown)
end

server_root = '#{Path.absname("test/sample_pages")}'
test_server_config = [
  port: 9090,
  server_name: 'hound_test_server',
  server_root: server_root,
  document_root: server_root,
  bind_address: {127, 0, 0, 1}
]

{:ok, pid} = :inets.start(:httpd, test_server_config)

IO.puts "Stopping Hound and restarting with options for test suite..."
:ok = Application.stop(:hound)
Hound.Supervisor.start_link(
  driver: driver,
  app_port: 9090
)

System.at_exit fn(_exit_status) ->
  :ok = :inets.stop(:httpd, pid)
end

ExUnit.start [max_cases: 5]
