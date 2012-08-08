if [[ $HOMENAME == "red" ]] {
	export HOME=/cs/home/$USER
        export LD_LIBRARY_PATH=/cs/local/lib:/cse/home/cse03307/os/lib;
        export PATH=/cs/home/cse03307/python/bin:/cs/home/cse03307/perl5/lib/perl5/auto/share/dist/Cope:/cse/home/cse03307/os/bin:/cs/local/bin:/usr/lib64/qt-3.3/bin:/usr/bin:/bin:/usr/sbin:/sbin:/xsys/bin;
        export C_INCLUDE_PATH=/cse/home/cse03307/os/include;
        export CPLUS_INCLUDE_PATH=/cse/home/cse03307/os/include;
        export SHELL=/bin/zsh;
        export PYTHONPATH=/cs/home/cse03307/python/lib/python;
        export PERL_MB_OPT="--install_base /cs/home/cse03307/perl5";
        export PERL_MM_OPT="INSTALL_BASE=/cs/home/cse03307/perl5";
        export PERL5LIB="/cs/home/cse03307/perl5/lib/perl5/x86_64-linux:/cs/home/cse03307/perl5/lib/perl5";
        export PATH="/cs/home/cse03307/perl5/bin:$PATH";
        export ACLOCAL_PATH="/cse/local/share/aclocal:/cse/local/share/aclocal-1.11:/cse/home/cse03307/os/share/aclocal";
        export PKG_CONFIG_PATH="/cse/home/cse03307/os/lib/pkgconfig:/cse/home/cse03307/os/share/pkgconfig";
}
if [[ $TERM == "xterm" ]] {
        export TERM="xterm-256color"
}

if [[ -d "/usr/local/lib/cw" ]] {
        export PATH="/usr/local/lib/cw:$PATH"
}
