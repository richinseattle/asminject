#include <stdio.h>
#include <ruby/ruby.h>

/* 

	gcc -o execute_ruby_code-x64 -I/usr/include/ruby-2.7.0 -I/usr/include/x86_64-linux-gnu/ruby-2.7.0 -O0 -m64 execute_ruby_code.c -L/usr/lib/x86_64-linux-gnu -lruby-2.7 -m64 -no-pie
	gcc -o execute_ruby_code-arm32-eabi -I/usr/include/ruby-2.5.0 -I/usr/include/arm-linux-gnueabihf/ruby-2.5.0 -O0 -fPIC -pie execute_ruby_code.c -L/usr/lib/arm-linux-gnueabihf -lruby-2.5
*/

int main ( int argc, char ** argv) 
{
  ruby_sysinit(&argc, &argv);
  RUBY_INIT_STACK;
  ruby_init();
  ruby_init_loadpath();
  rb_require("fileutils");
  rb_eval_string("FileUtils.cp('/etc/passwd', '/home/user');");
  return ruby_cleanup(0);
}