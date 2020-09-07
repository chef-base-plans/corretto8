title 'Tests to confirm corretto8 works as expected'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'corretto8')

control 'core-plans-corretto8-works' do
  impact 1.0
  title 'Ensure corretto8 works as expected'
  desc '
  Verify corretto8 by ensuring that
  (1) its installation directory exists 
  (2) all binaries, with exception of jconsole, orbd, and
      java-rmi.cgi, return expected output. The exceptions are ignored here 
      since they are not easily tested: for example jconsole needs a jvm to connect to; orbd
      starts a daemon, etc
  '
  
  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stderr') { should be_empty }
  end
  
  plan_pkg_version = plan_installation_directory.stdout.split("/")[5]
  {
    "appletviewer" => {},
    "extcheck" => {
      command_suffix: "",
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "idlj" => {
      command_suffix: "-version",
      command_output_pattern: /IDL-to-Java compiler\s+\(portable\),\s+version/,
    },
    "jar" => {
      command_suffix: "",
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "jarsigner" => {},
    "java" => {
      io: "stderr",
    },
    # ignoring this as per https://stackoverflow.com/questions/25055466/what-is-java-rmi-exe
    # "java-rmi.cgi" => {},
    "javac" => {
      io: "stderr",
    },
    "javadoc" => {},
    "javafxpackager" => {
      command_prefix: "hab pkg exec #{plan_origin}/#{plan_name}",
      command_output_pattern: /javafxpackager has been renamed javapackager/,
    },
    "javah" => {
      command_output_pattern: /javah \[options\] <classes>/,
    },
    "javap" => {},
    "javapackager" => {
      command_prefix: "hab pkg exec #{plan_origin}/#{plan_name}",
    },
    "jcmd" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    # ignore because we need a JVM to connect to...
    # "jconsole" => {},
    "jdb" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "jdeps" => {},
    "jhat" => {
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "jinfo" => {
      io: "stderr",
      command_output_pattern: /jinfo \[option\] <pid>/,
    },
    "jjs" => {
      io: "stderr",
      command_output_pattern: /jjs \[<options>\] <files> \[-- <arguments>\]/,
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "jmap" => {
      io: "stderr",
      command_output_pattern: /jmap \[option\] <pid>/,
    },
    "jps" => {
      io: "stderr",
    },
    "jrunscript" => {
      io: "stderr",
    },
    "jsadebugd" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "jstack" => {
      io: "stderr",
      command_output_pattern: /jstack \[-l\] <pid>/,
    },
    "jstat" => {},
    "jstatd" => {
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "keytool" => {
      io: "stderr",
      command_output_pattern: /Key and Certificate Management Tool/,
    },
    # ensure chinese characters are correctly converted to utf-8 
    "native2ascii" => {
      command_suffix: "-encoding utf-8 <(echo '漢字')",
      command_output_pattern: /\\u6f22\\u5b57/,
    },
    # ignoring orbd because this starts a daemon
    # "orbd" => {},
    "pack200" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "policytool" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "rmic" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "rmid" => {
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "rmiregistry" => {
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "schemagen" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "serialver" => {
      io: "stderr",
      command_suffix: "",
      exit_pattern: /^[^0]{1}\d*$/,
      command_output_pattern: /use: serialver \[-classpath classpath\]/,
    },
    "servertool" => {
      command_prefix: "echo 'quit' | ",
      command_suffix: "",
      command_output_pattern: /Welcome to the Java IDL Server Tool/,
    },
    # start server, verify output, kill after 1 second timeout
    "tnameserv" => {
      command_prefix: "timeout 1",
      exit_pattern: /^[^0]{1}\d*$/,
      command_output_pattern: /TransientNameServer: setting port for initial object references to: 900/,
    },
    "unpack200" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "wsgen" => {},
    "wsimport" => {},
    "xjc" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
  }.each do |binary_name, value|
    # set default values if each binary doesn't define an over-ride
    command_prefix = value[:command_prefix] || ""
    command_suffix = value[:command_suffix] || "-help"
    command_output_pattern = value[:command_output_pattern] || /usage:.+#{binary_name}/i 
    exit_pattern = value[:exit_pattern] || /^[0]$/ # use /^[^0]{1}\d*$/ for non-zero exit status
    io = value[:io] || "stdout"
  
    # verify output
    command_full_path = File.join(plan_installation_directory.stdout.strip, "bin", binary_name)
    describe bash("#{command_prefix} #{command_full_path} #{command_suffix}") do
      its('exit_status') { should cmp exit_pattern }
      its(io) { should match command_output_pattern }
    end
  end

  {
    "java" => {
      io: "stderr",
    },
    "jjs" => {
      io: "stderr",
      command_output_pattern: /jjs \[<options>\] <files> \[-- <arguments>\]/,
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "keytool" => {
      io: "stderr",
      command_output_pattern: /Key and Certificate Management Tool/,
    },
    # ignoring orbd because this starts a daemon
    # "orbd" => {},
    "pack200" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "policytool" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "rmid" => {
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "rmiregistry" => {
      io: "stderr",
      exit_pattern: /^[^0]{1}\d*$/,
    },
    "servertool" => {
      command_prefix: "echo 'quit' | ",
      command_suffix: "",
      command_output_pattern: /Welcome to the Java IDL Server Tool/,
    },
    # start server, verify output, kill after 1 second timeout
    "tnameserv" => {
      command_prefix: "timeout 1",
      exit_pattern: /^[^0]{1}\d*$/,
      command_output_pattern: /TransientNameServer: setting port for initial object references to: 900/,
    },
    "unpack200" => {
      exit_pattern: /^[^0]{1}\d*$/,
    },
  }.each do |binary_name, value|
    # set default values if each binary doesn't define an over-ride
    command_prefix = value[:command_prefix] || ""
    command_suffix = value[:command_suffix] || "-help"
    command_output_pattern = value[:command_output_pattern] || /usage:.+#{binary_name}/i 
    exit_pattern = value[:exit_pattern] || /^[0]$/ # use /^[^0]{1}\d*$/ for non-zero exit status
    io = value[:io] || "stdout"
  
    # verify output
    command_full_path = File.join(plan_installation_directory.stdout.strip, "jre", "bin", binary_name)
    describe bash("#{command_prefix} #{command_full_path} #{command_suffix}") do
      its('exit_status') { should cmp exit_pattern }
      its(io) { should match command_output_pattern }
    end
  end
end