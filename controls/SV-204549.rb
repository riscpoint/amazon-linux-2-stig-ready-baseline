control 'AMZL-02-730700' do
  title 'The Amazon Linux 2 operating system must audit all uses of the sudoers file and all files in the
    /etc/sudoers.d/ directory.'
  desc 'Reconstruction of harmful events or forensic analysis is not possible if audit records do not contain enough
    information.
    At a minimum, the organization must audit the full-text recording of privileged access commands. The organization
    must maintain audit trails in sufficient detail to reconstruct events to determine the cause and impact of
    compromise.'
  desc 'check', 'Verify the operating system generates audit records when successful/unsuccessful attempts to access
    the "/etc/sudoers" file and files in the "/etc/sudoers.d/" directory.
    Check for modification of the following files being audited by performing the following commands to check the file
    system rules in "/etc/audit/audit.rules":
    # grep -i "/etc/sudoers" /etc/audit/audit.rules
    -w /etc/sudoers -p wa -k privileged-actions
    # grep -i "/etc/sudoers.d/" /etc/audit/audit.rules
    -w /etc/sudoers.d/ -p wa -k privileged-actions
    If the commands do not return output that match the examples, this is a finding.'
  desc 'fix', 'Configure the operating system to generate audit records when successful/unsuccessful attempts to
    access the "/etc/sudoers" file and files in the "/etc/sudoers.d/" directory.
    Add or update the following rule in "/etc/audit/rules.d/audit.rules":
    -w /etc/sudoers -p wa -k privileged-actions
    -w /etc/sudoers.d/ -p wa -k privileged-actions
    The audit daemon must be restarted for the changes to take effect.'
  impact 0.5
  tag severity: 'medium'
  tag gtitle: 'SRG-OS-000037-GPOS-00015'
  tag satisfies: ['SRG-OS-000062-GPOS-00031', 'SRG-OS-000004-GPOS-00004', 'SRG-OS-000037-GPOS-00015', 'SRG-OS-000042-GPOS-00020', 'SRG-OS-000062-GPOS-00031', 'SRG-OS-000304-GPOS-00121', 'SRG-OS-000392-GPOS-00172', 'SRG-OS-000462-GPOS-00206', 'SRG-OS-000470-GPOS-00214', 'SRG-OS-000471-GPOS-00215', 'SRG-OS-000239-GPOS-00089', 'SRG-OS-000240-GPOS-00090', 'SRG-OS-000241-GPOS-00091', 'SRG-OS-000303-GPOS-00120', 'SRG-OS-000304-GPOS-00121', 'SRG-OS-000466-GPOS-00210', 'SRG-OS-000476-GPOS-00221']
  tag stig_id: 'AMZL-02-730700'
  tag cci: ['CCI-000130', 'CCI-000135', 'CCI-000172', 'CCI-002884']
  tag nist: ['AU-3', 'AU-3 (1)', 'AU-12 c', 'MA-4 (1) (a)', 'AU-3 a']
  tag subsystems: ['audit', 'auditd', 'audit_rule']
  tag 'host'

  audit_commands = ['/etc/sudoers', '/etc/sudoers.d/']

  if virtualization.system.eql?('docker')
    impact 0.0
    describe 'Control not applicable - audit config must be done on the host' do
      skip 'Control not applicable - audit config must be done on the host'
    end
  else
    describe 'Command' do
      audit_commands.each do |audit_command|
        it "#{audit_command} is audited properly" do
          audit_rule = auditd.file(audit_command)
          expect(audit_rule).to exist
          expect(audit_rule.key).to cmp 'privileged-actions'
          expect(audit_rule.permissions.flatten).to include('w', 'a')
        end
      end
    end
  end
end
