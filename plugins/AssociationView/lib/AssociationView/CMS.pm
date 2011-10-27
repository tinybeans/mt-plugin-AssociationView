package AssociationView::CMS;
use strict;
use utf8;
use MT::Website;
use MT::Blog;
###
##
#
use MT::Log;
use Data::Dumper;
sub doLog {
    my ($msg) = @_;     return unless defined($msg);
    my $log = MT::Log->new;
    $log->message($msg) ;
    $log->save or die $log->errstr;
}
#
##
###

sub insert_website {
    my ($cb, $app, $tmpl_ref) = @_;
    doLog('callback seikou');

    my @websites = MT::Website->load(undef);
    my @blogs = MT::Blog->load(undef);

    my $json_blogs = '{';
    my $json_websites = '{';

    foreach my $blog (@blogs) {
        $json_blogs .= '"blog-' . $blog->id . '":"website-' . $blog->parent_id . '",';
    }
    $json_blogs =~ s/,$/}/;

    foreach my $website (@websites) {
        $json_websites .= '"website-' . $website->id . '":"' . $website->name . '",';
    }
    $json_websites =~ s/,$/}/;

    doLog($json_blogs);
    my $javascript = <<__JAVASCRIPT__;
    <script type="text/javascript">
    // <![CDATA[
    jQuery(window).bind('listReady', function(){
        alert('ok');
    });
    var blogs = $json_blogs;
    var websites = $json_websites;
    jQuery('#blog-panel')
        .find('th.primary')
            .after('<th class="col head panel-label"><span class="col-label">ウェブサイト</span></th>');
    for (var key in blogs) {
        var websiteID = blogs[key];
        jQuery('#' + key + ':eq(2)').after('<td class="col panel-label"><label>' + websites[websiteID] + '</label></td>');
    }
    // ]]>
    </script>
__JAVASCRIPT__
    $$tmpl_ref = $$tmpl_ref . $javascript;
}

sub template_param {
    my ($cb, $app, $param, $tmpl) = @_;
#     doLog('template_param');
#     doLog('$param[before] : '.Dumper($param));
    my @websites = MT::Website->load(undef);
    my $websites_obj;
    foreach my $website (@websites) {
        doLog(Dumper($website));
        my $key = 'website_' . $website->id;
        my $val = $website->name;
        $websites_obj->{$key} = $val;
    }
    doLog(Dumper($websites_obj));
#     my @panel_loop = $param->{'panel_loop'};
#     doLog(Dumper(@panel_loop));
#     foreach my $panel_loop (@panel_loop) {
#         doLog(Dumper($panel_loop->{'object_loop'}));
#     }
    my $blogs = $param->{'panel_loop'}[2]{'object_loop'};
#     doLog('$blogs[before] : '.Dumper($blogs));
    foreach my $blog (@$blogs) {
        my $parent_id = 'website_' . $blog->{'parent_id'};
        my $blog_name = $blog->{'label'};
        $blog->{'label'} = $blog_name . '(' . $websites_obj->{$parent_id} . ')';
#         doLog('*'.Dumper($blog));
    }
#     doLog('$blogs[after] : '.Dumper($blogs));

    $param->{'panel_loop'}[2]{'object_loop'} = $blogs;
#     doLog('$param[after] : '.Dumper($param));
    return 1;
}
1;