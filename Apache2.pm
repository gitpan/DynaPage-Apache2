
=head1 NAME

DynaPage::Apache2 - Apache2 mod_perl handler for DynaPage::Document 

 #------------------------------------------------------
 # (C) Daniel Peder & Infoset s.r.o., all rights reserved
 # http://www.infoset.com, Daniel.Peder@infoset.com
 #------------------------------------------------------

=cut

###													###
###	size of <TAB> in this document is 4 characters	###
###													###

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: package
#

	package DynaPage::Apache2;


### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: version
#

	use vars qw( $VERSION $VERSION_LABEL $REVISION $REVISION_DATETIME $REVISION_LABEL $PROG_LABEL );

	$VERSION           = '0.90';
	
	$REVISION          = (qw$Revision: 1.9 $)[1];
	$REVISION_DATETIME = join(' ',(qw$Date: 2005/01/14 10:51:01 $)[1,2]);
	$REVISION_LABEL    = '$Id: Apache2.pm,v 1.9 2005/01/14 10:51:01 root Exp root $';
	$VERSION_LABEL     = "$VERSION (rev. $REVISION $REVISION_DATETIME)";
	$PROG_LABEL        = __PACKAGE__." - ver. $VERSION_LABEL";

=pod

 $Revision: 1.9 $
 $Date: 2005/01/14 10:51:01 $

=cut


### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: debug
#

	use vars qw( $DEBUG ); $DEBUG=0;
	

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: intro
#

=head1 SYNOPSIS

 # content of Apache2 config file
 # file: /etc/httpd/conf.d/perl.conf
 
 ...
 
    PerlModule Apache2
    PerlModule DynaPage::Apache2

    AddType text/html .info
    DirectoryIndex index.info

    <Location ~ "\.info$">
        SetHandler perl-script
        PerlResponseHandler DynaPage::Apache2
        PerlOptions +ParseHeaders
        Options +ExecCGI
    </Location>

  ...
  
=head1 DESCRIPTION

=cut



### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: modules use
#

	require 5.005_62;

	use strict                  ;
	use warnings                ;
	
	use	Apache::Const 			;
	use	APR::Const 				;
	use	APR::Table 				;
	use	ModPerl::Const			;

	use	Apache::RequestRec		;
	use	Apache::RequestUtil		;
	use	Apache::RequestIO ()	;
	
	use	CGI						;
	use CGI::Cookie    			;
	use URI                     ;
	use URI::URL                ;
	
	use File::Spec              ;
	
	use IO::File::String        ;
	
	use	DynaPage::Document		;
	use DynaPage::Document::ext::include;
	

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: methods
#

=head1 METHODS

=over 4

=cut








### ##########################################################################

=item handler ( $apache_request_object )

=cut

### --------------------------------------------------------------------------
sub handler : method
### --------------------------------------------------------------------------
{
	my(		$class, $r		)=@_;
	
	my	$self = {};
		bless( $self, $class );
	
	my	$filename 		= $r->filename; 
		return			Apache::NOT_FOUND unless -f($filename); # because we've been catched by location ~.info
	my  $modified       = -M(_);
	my	$root_dir		= File::Spec->catdir( $r->document_root, ( $ENV{'MAP_DIR'} || '' ) );
	my	$options		= { 
            Document => "/$filename", 
            DocumentModified => $modified,
            RootDir => $root_dir ,
        };
	my	$doc			= DynaPage::Document->new( $options );
	
		# $doc->CallHook( 'Init' );
		
		if( $doc->GetSignal ) {
    		if( my $target_string = $doc->GetSignal('HTTP_REDIRECT') )
    		{
                my $base_url = sprintf '%s://%s%s', ( lc($ENV{SERVER_PROTOCOL}) =~ m/^([a-z]+)/ )[0], $ENV{HTTP_HOST}, ($ENV{REQUEST_URI}||'/');
                my $target_url = URI::URL->new( $target_string, $base_url );
    			$r->headers_out->add( Location => $target_url->abs );
    			return Apache::REDIRECT;
    		}
    		elsif( $doc->GetSignal( 'HTTP_DECLINED'))
    		{
    			return Apache::DECLINED;
    		}
        }

	my	$Content		= $doc->Render();

	my	$ContentType	= $doc->Sourcer->Get('!content-type') || 'text/html';
	my	$ContentCharset	= $doc->Sourcer->Get('!content-charset');
		$ContentType	.= "; charset=$ContentCharset" if $ContentCharset;
	my	$ContentLanguage = $doc->Sourcer->Get('!content-language') || 'en';

	    $r->content_type($ContentType); # TODO: check if there 
	    $r->headers_out->add( 'X-Handler-Signature' => $PROG_LABEL );

#	my  $ContentLanguages = $r->content_languages();
#	    $ContentLanguages->add($ContentLanguage);
#	    $r->content_languages([$ContentLanguage]); # must be APR::ArrayHeader

	    $r->discard_request_body();

	    $r->print( $Content );
	
	return Apache::OK;
}




1;


### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: pod epilogue
#

=back

=cut

=head1 AUTHOR

 Daniel Peder

 <Daniel.Peder@Infoset.COM>
 http://www.infoset.com

=head1 SEE ALSO

	DynaPage::Document DynaPage::Sourcer DynaPage::Template
	
=cut

__DATA__

__END__

### //////////////////////////////////////////////////////////////////////////
#
#	SECTION: changes log
#

	$Log: Apache2.pm,v $
	Revision 1.9  2005/01/14 10:51:01  root
	*** empty log message ***

	Revision 1.7  2005/01/13 21:29:56  root
	*** empty log message ***

	Revision 1.3  2004/12/30 23:06:48  root
	*** empty log message ***

	Revision 1.1  2004/11/27 16:58:26  root
	Initial revision


