package AssociationView::CMS;
use strict;
use utf8;
use MT::Website;
use MT::Blog;

sub template_param {
    my ($cb, $app, $param, $tmpl) = @_;
    my @websites = MT::Website->load(undef);
    my $websites_obj;
    foreach my $website (@websites) {
        my $key = 'website_' . $website->id;
        my $val = $website->name;
        $websites_obj->{$key} = $val;
    }
    my $blogs = $param->{'panel_loop'}[2]{'object_loop'};
    foreach my $blog (@$blogs) {
        my $parent_id = 'website_' . $blog->{'parent_id'};
        my $blog_name = $blog->{'label'};
        $blog->{'label'} = $blog_name . '(' . $websites_obj->{$parent_id} . ')';
    }

    $param->{'panel_loop'}[2]{'object_loop'} = $blogs;
    return 1;
}

1;