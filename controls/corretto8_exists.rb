title 'Tests to confirm corretto8 exists'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'corretto8')

control 'core-plans-corretto8-exists' do
  impact 1.0
  title 'Ensure corretto8 exists'
  desc '
  Verify corretto8 by ensuring bin/java 
  (1) exists and
  (2) is executable'
  
  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stderr') { should be_empty }
  end

  [
    "appletviewer",
    "extcheck",
    "idlj",
    "jar",
    "jarsigner",
    "java",
    "java-rmi.cgi",
    "javac",
    "javadoc",
    "javafxpackager",
    "javah",
    "javap",
    "javapackager",
    "jcmd",
    "jconsole",
    "jdb",
    "jdeps",
    "jhat",
    "jinfo",
    "jjs",
    "jmap",
    "jps",
    "jrunscript",
    "jsadebugd",
    "jstack",
    "jstat",
    "jstatd",
    "keytool",
    "native2ascii",
    "orbd",
    "pack200",
    "policytool",
    "rmic",
    "rmid",
    "rmiregistry",
    "schemagen",
    "serialver",
    "servertool",
    "tnameserv",
    "unpack200",
    "wsgen",
    "wsimport",
    "xjc",
  ].each do |binary_name|
      command_full_path = File.join(plan_installation_directory.stdout.strip, "bin", binary_name)
      describe file(command_full_path) do
        it { should exist }
        it { should be_executable }
      end
    end
end
