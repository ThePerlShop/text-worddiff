use Module::Build;

my $build = Module::Build->new(
    module_name        => 'Text::WordDiff',
    license            => 'perl',
    create_makefile_pl => 'passthrough',
    create_readme      => 1,
    configure_requires => { 'Module::Build' => '0.2701' },
    recommends         => { 'Test::Pod'     => '1.20'   },
    requires           => {
        Algorithm::Diff => '1.19',
        Term::ANSIColor => '0',
        HTML::Entities  => '0',
    },
    build_requires     => {
        'Module::Build' => '0.2701',
        'Test::More'    => '0.17',
        'File::Spec'    => '0',
    },
);
$build->create_build_script;
