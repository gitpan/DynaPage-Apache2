use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(

	# depend => { Makefile => '$(VERSION_FROM)' },

    'NAME'           => 'DynaPage::Apache2',
    'VERSION_FROM'   => 'Apache2.pm', # finds $VERSION
    'PREREQ_PM'      => 
	                    { # e.g., Module::Name => 1.1
							strict			=> 0,
							warnings		=> 0,
							Test::Easy		=> 1.01,
							
							DynaPage::Document => 0,
							DynaPage::Document::ext::include => 0,
                            
                            Apache::Const 			=>0,
                            APR::Const 				=>0,
                            APR::Table 				=>0,
                            ModPerl::Const			=>0,
                            
                            Apache::RequestRec		=>0,
                            Apache::RequestUtil		=>0,
                            Apache::RequestIO		=>0,
                            
                            CGI						=>0,
                            CGI::Cookie    			=>0,
                            URI                     =>0,
                            URI::URL                =>0,
                            
                            File::Spec              =>0,
                            
                            IO::File::String        =>0,

						},
    ($] >= 5.005 ? (
      ABSTRACT_FROM  => 'Apache2.pm', 
      AUTHOR         => 'Daniel Peder <Daniel.Peder@infoset.com>',
    ) : ()),
);


sub MY::postamble { q{

docs : README

README: Apache2.pm
	pod2text --loose Apache2.pm > README

xdist:
	[ -f MANIFEST ] && rm -f MANIFEST ; make realclean docs manifest tardist;

}; }
