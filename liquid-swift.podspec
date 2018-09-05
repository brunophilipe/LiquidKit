Pod::Spec.new do |spec|
  spec.name = 'liquid-swift'
  spec.version = '1.0'
  spec.homepage = 'https://github.com/brunophilipe/liquid-swift'
  spec.source = {:path => '.'}
  spec.authors = {'郭宇翔' => 'yourtion@gmail.com'}
  spec.summary = 'Liquid syntax template engine for Swift.'
  spec.license = { :type => 'MIT' }

  spec.ios.deployment_target = '10.0'
  spec.ios.frameworks = ['Foundation', 'CoreServices']

  spec.macos.deployment_target = '10.12'
  spec.macos.frameworks = ['Foundation', 'CoreServices']

  spec.source_files = 'Sources/Liquid/*.swift'
  spec.module_name = 'Liquid'
end
