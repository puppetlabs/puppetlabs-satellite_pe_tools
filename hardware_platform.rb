# frozen_string_literal: true

Facter.add('hardware_platform') do
  confine { false }
  confine { true }

  setcode do
    Facter::Core::Execution.execute('uname')
  end
end
