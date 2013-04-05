# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'coffeescript', :input => 'src', :output => 'lib'

guard 'livereload' do
  watch(%r{.+\.(css|html|js)$})
end

guard 'process', :name => 'Copy to min', :command => 'cp lib/onedollar.js lib/onedollar.min.js' do
  watch %r{lib/onedollar.js}
end

guard 'process', :name => 'Copy to min', :command => 'cp lib/jquery.onedollar.js lib/jquery.onedollar.min.js' do
  watch %r{lib/jquery.onedollar.js}
end

guard 'uglify', :destination_file => "lib/onedollar.min.js" do
  watch ('lib/onedollar.min.js')
end

guard 'uglify', :destination_file => "lib/jquery.onedollar.min.js" do
  watch ('lib/jquery.onedollar.min.js')
end