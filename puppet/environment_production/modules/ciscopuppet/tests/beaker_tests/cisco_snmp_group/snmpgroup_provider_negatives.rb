###############################################################################
# Copyright (c) 2015 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################
# TestCase Name:
# -------------
# SnmpGroup-Provider-Negatives.rb
#
# TestCase Prerequisites:
# -----------------------
# This is a SNMPGROUP resource testcase for Puppet Agent on Nexus devices.
# The test case assumes the following prerequisites are already satisfied:
# A. Populating the HOSTS configuration file with the agent and master
# information.
# B. Enabling SSH connection prerequisites on the N9K switch based Agent.
# C. Starting of Puppet master server on master.
# D. Sending to and signing of Puppet agent certificate request on master.
#
# TestCase:
# ---------
# This is a SNMPGROUP resource test that tests for negative values for
# aaa_user_cache_timeout, global_enforce_priv, packet_size, protocol,
# tcp_session_auth, contact and location attributes of a
# cisco_snmp_server resource.
#
# There are 2 sections to the testcase: Setup, group of teststeps.
# The 1st step is the Setup teststep that cleans up the switch state.
# The next set of teststeps deal with attribute negative tests and their
# verification using Puppet Agent and the switch running-config.
#
# The testcode checks for exit_codes from Puppet Agent, Vegas shell and
# Bash shell command executions. For Vegas shell and Bash shell command
# string executions, this is the exit_code convention:
# 0 - successful command execution, > 0 - failed command execution.
# For Puppet Agent command string executions, this is the exit_code convention:
# 0 - no changes have occurred, 1 - errors have occurred,
# 2 - changes have occurred, 4 - failures have occurred and
# 6 - changes and failures have occurred.
# 0 is the default exit_code checked in Beaker::DSL::Helpers::on() method.
# The testcode also uses RegExp pattern matching on stdout or output IO
# instance attributes of Result object from on() method invocation.
#
###############################################################################

# Require UtilityLib.rb and SnmpGroupLib.rb paths.
require File.expand_path('../../lib/utilitylib.rb', __FILE__)
require File.expand_path('../snmpgrouplib.rb', __FILE__)

result = 'PASS'
testheader = 'SNMPGROUP Resource :: All Attributes Negatives'

test_name "TestCase :: #{testheader}" do
  # @step [Step] Sets up switch for provider test.
  step 'TestStep :: Setup switch for provider test' do
    # In NX-OS there's no direct configuration of SNMP groups.
    # Instead SNMP groups correspond to user roles, and our Puppet provider
    # for cisco_snmp_group provides read-only access.

    # Let's check and make sure that an expected default group/role is present
    # and an unexpected non-default group/role is absent

    # Expected exit_code is 0 since this is a vegas shell cmd.
    cmd_str = get_vshell_cmd('show snmp group')
    on(agent, cmd_str) do
      # Flag is set to false to check for presence of RegExp pattern in stdout.
      search_pattern_in_output(stdout,
                               [/Role: *network-operator/],
                               false, self, logger)
      # Flag is set to true to check for absence of RegExp pattern in stdout.
      search_pattern_in_output(stdout,
                               [/Role: *go-jackets/],
                               true, self, logger)
    end
    logger.info("Setup switch for provider test :: #{result}")
  end

  step 'TestStep :: Get negative test manifest #1 from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SnmpGroupLib.create_snmpgroup_manifest_negative_1)

    # Expected exit_code is 4 since this is a puppet agent cmd with failure.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [4])

    logger.info("Get negative test manifest #1 from master :: #{result}")
  end

  step 'TestStep :: Get negative test manifest #2 from master' do
    # Expected exit_code is 0 since this is a bash shell cmd.
    on(master, SnmpGroupLib.create_snmpgroup_manifest_negative_2)

    # Expected exit_code is 4 since this is a puppet agent cmd with failure.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      'agent -t', options)
    on(agent, cmd_str, acceptable_exit_codes: [4])

    logger.info("Get negative test manifest #2 from master :: #{result}")
  end

  # @step [Step] Checks cisco_snmp_group resource on agent using resource cmd.
  step 'TestStep :: Check cisco_snmp_group resource state on agent' do
    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_snmp_group 'network-operator'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure' => 'present' },
                               false, self, logger)
    end

    # Expected exit_code is 0 since this is a puppet resource cmd.
    # Flag is set to false to check for presence of RegExp pattern in stdout.
    cmd_str = get_namespace_cmd(agent, PUPPET_BINPATH +
      "resource cisco_snmp_group 'go-jackets'", options)
    on(agent, cmd_str) do
      search_pattern_in_output(stdout,
                               { 'ensure' => 'absent' },
                               false, self, logger)
    end

    logger.info("Check cisco_snmp_group resource state on agent :: #{result}")
  end

  # @step [Step] Checks snmpgroup instance on agent using switch show cli cmds.
  step 'TestStep :: Check snmpgroup instance state in CLI' do
    # Expected exit_code is 0 since this is a vegas shell cmd.
    cmd_str = get_vshell_cmd('show snmp group')
    on(agent, cmd_str) do
      # Flag is set to false to check for presence of RegExp pattern in stdout.
      search_pattern_in_output(stdout,
                               [/Role: *network-operator/],
                               false, self, logger)
      # Flag is set to true to check for absence of RegExp pattern in stdout.
      search_pattern_in_output(stdout,
                               [/Role: *go-jackets/],
                               true, self, logger)
    end

    logger.info("Check snmpgroup instance state in CLI:: #{result}")
  end

  # @raise [PassTest/FailTest] Raises PassTest/FailTest exception using result.
  raise_passfail_exception(result, testheader, self, logger)
end

logger.info("TestCase :: #{testheader} :: End")
