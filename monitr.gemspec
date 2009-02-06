Gem::Specification.new do |s|
  s.name = %q{monitr}
  s.version = "0.7.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Preston-Werner"]
  s.date = %q{2008-12-10}
  s.default_executable = %q{monitr}
  s.description = %q{Monitr is an easy to configure, easy to extend monitoring framework written in Ruby.}
  s.email = %q{tom@rubyisawesome.com}
  s.executables = ["monitr"]
  s.extensions = ["ext/monitr/extconf.rb"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/monitr", "examples/events.monitr", "examples/gravatar.monitr", "examples/single.monitr", "ext/monitr/extconf.rb", "ext/monitr/kqueue_handler.c", "ext/monitr/netlink_handler.c", "init/monitr", "lib/monitr.rb", "lib/monitr/behavior.rb", "lib/monitr/behaviors/clean_pid_file.rb", "lib/monitr/behaviors/clean_unix_socket.rb", "lib/monitr/behaviors/notify_when_flapping.rb", "lib/monitr/cli/command.rb", "lib/monitr/cli/run.rb", "lib/monitr/cli/version.rb", "lib/monitr/condition.rb", "lib/monitr/conditions/always.rb", "lib/monitr/conditions/complex.rb", "lib/monitr/conditions/cpu_usage.rb", "lib/monitr/conditions/degrading_lambda.rb", "lib/monitr/conditions/disk_usage.rb", "lib/monitr/conditions/file_mtime.rb", "lib/monitr/conditions/flapping.rb", "lib/monitr/conditions/http_response_code.rb", "lib/monitr/conditions/lambda.rb", "lib/monitr/conditions/memory_usage.rb", "lib/monitr/conditions/process_exits.rb", "lib/monitr/conditions/process_running.rb", "lib/monitr/conditions/tries.rb", "lib/monitr/configurable.rb", "lib/monitr/contact.rb", "lib/monitr/contacts/campfire.rb", "lib/monitr/contacts/email.rb", "lib/monitr/contacts/jabber.rb", "lib/monitr/contacts/twitter.rb", "lib/monitr/contacts/webhook.rb", "lib/monitr/dependency_graph.rb", "lib/monitr/diagnostics.rb", "lib/monitr/driver.rb", "lib/monitr/errors.rb", "lib/monitr/event_handler.rb", "lib/monitr/event_handlers/dummy_handler.rb", "lib/monitr/event_handlers/kqueue_handler.rb", "lib/monitr/event_handlers/netlink_handler.rb", "lib/monitr/logger.rb", "lib/monitr/metric.rb", "lib/monitr/process.rb", "lib/monitr/registry.rb", "lib/monitr/simple_logger.rb", "lib/monitr/socket.rb", "lib/monitr/sugar.rb", "lib/monitr/system/portable_poller.rb", "lib/monitr/system/process.rb", "lib/monitr/system/slash_proc_poller.rb", "lib/monitr/task.rb", "lib/monitr/timeline.rb", "lib/monitr/trigger.rb", "lib/monitr/watch.rb", "test/configs/child_events/child_events.monitr", "test/configs/child_events/simple_server.rb", "test/configs/child_polls/child_polls.monitr", "test/configs/child_polls/simple_server.rb", "test/configs/complex/complex.monitr", "test/configs/complex/simple_server.rb", "test/configs/contact/contact.monitr", "test/configs/contact/simple_server.rb", "test/configs/daemon_events/daemon_events.monitr", "test/configs/daemon_events/simple_server.rb", "test/configs/daemon_events/simple_server_stop.rb", "test/configs/daemon_polls/daemon_polls.monitr", "test/configs/daemon_polls/simple_server.rb", "test/configs/degrading_lambda/degrading_lambda.monitr", "test/configs/degrading_lambda/tcp_server.rb", "test/configs/matias/matias.monitr", "test/configs/real.rb", "test/configs/running_load/running_load.monitr", "test/configs/stress/simple_server.rb", "test/configs/stress/stress.monitr", "test/configs/task/logs/.placeholder", "test/configs/task/task.monitr", "test/configs/test.rb", "test/helper.rb", "test/suite.rb", "test/test_behavior.rb", "test/test_campfire.rb", "test/test_condition.rb", "test/test_conditions_disk_usage.rb", "test/test_conditions_http_response_code.rb", "test/test_conditions_process_running.rb", "test/test_conditions_tries.rb", "test/test_contact.rb", "test/test_dependency_graph.rb", "test/test_driver.rb", "test/test_email.rb", "test/test_event_handler.rb", "test/test_monitr.rb", "test/test_handlers_kqueue_handler.rb", "test/test_logger.rb", "test/test_metric.rb", "test/test_process.rb", "test/test_registry.rb", "test/test_socket.rb", "test/test_sugar.rb", "test/test_system_portable_poller.rb", "test/test_system_process.rb", "test/test_task.rb", "test/test_timeline.rb", "test/test_trigger.rb", "test/test_watch.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://monitr.rubyforge.org/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = %q{monitr}
  s.rubygems_version = %q{0.0.1}
  s.summary = %q{Like monit, only ruby awesome}
  s.test_files = ["test/test_process.rb", "test/test_watch.rb", "test/test_system_portable_poller.rb", "test/test_conditions_tries.rb", "test/test_task.rb", "test/test_condition.rb", "test/test_timeline.rb", "test/test_logger.rb", "test/test_conditions_process_running.rb", "test/test_handlers_kqueue_handler.rb", "test/test_conditions_disk_usage.rb", "test/test_event_handler.rb", "test/test_driver.rb", "test/test_dependency_graph.rb", "test/test_metric.rb", "test/test_registry.rb", "test/test_behavior.rb", "test/test_socket.rb", "test/test_sugar.rb", "test/test_trigger.rb", "test/test_conditions_http_response_code.rb", "test/test_monitr.rb", "test/test_system_process.rb", "test/test_contact.rb"]
end
