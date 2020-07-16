# Maintainer: Kristen McWilliam <merritt_public at outlook dot com>
pkgname=nyrna
pkgver=1.1
pkgrel=6
pkgdesc='Simple program to pause games & applications'
arch=('x86_64')
url="https://github.com/Merrit/nyrna"
license=('GPL3 or any later version')
depends=('gtk3' 'libappindicator-gtk3' 'zenity')
makedepends=('go' 'gcc')
source=("$pkgname-$pkgver.tar.gz::https://github.com/Merrit/nyrna/archive/v$pkgver.tar.gz" "$pkgname.png" "$pkgname.desktop")
sha256sums=('41072a702a8aa74a70b7e3ca0d94f697cd6126d5df9943c12a5b1378650479af'
            'b29e378f1d70ee3cee5e8c1f4c1bb5f579ce261d1eb1e0ceb6ce2e82dd1091ff'
            'e915667767d03b3495516d7f96666159d17313726b1172dc79b162b0e0696181')

prepare(){
  cd "$pkgname-$pkgver"
}

build() {
  cd "$pkgname-$pkgver"
  export CGO_CPPFLAGS="${CPPFLAGS}"
  export CGO_CFLAGS="${CFLAGS}"
  export CGO_CXXFLAGS="${CXXFLAGS}"
  export CGO_LDFLAGS="${LDFLAGS}"
  export GOFLAGS="-buildmode=pie -trimpath -mod=readonly -modcacherw"
  go build
}

check() {
  cd "$pkgname-$pkgver"
}

package() {
  cd "$pkgname-$pkgver"
  install -Dm755 $pkgname "$pkgdir"/usr/bin/$pkgname
  install -Dm644 "../../$pkgname.desktop" "$pkgdir/usr/share/applications/$pkgname.desktop"
  install -Dm644 "../../$pkgname.png" "$pkgdir/usr/share/pixmaps/$pkgname.png"

}
