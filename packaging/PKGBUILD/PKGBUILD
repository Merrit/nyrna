# Maintainer: Kristen McWilliam <merritt_public at outlook dot com>
pkgname=nyrna
pkgver=1.2
pkgrel=1
pkgdesc='Simple program to pause games & applications'
arch=('x86_64')
url="https://github.com/Merrit/nyrna"
license=('GPL3 or any later version')
depends=('gtk3' 'libappindicator-gtk3' 'zenity')
makedepends=('go' 'gcc')
source=("$pkgname-$pkgver.tar.gz::https://github.com/Merrit/nyrna/archive/v$pkgver.tar.gz")
sha256sums=('ba6e81f9a91e74025ad2e1a0c027b15a13eb61b212107bc77fc479768ccf0fd9')

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
  install -Dm644 "$srcdir/$pkgname-$pkgver/packaging/PKGBUILD/$pkgname.desktop" "$pkgdir/usr/share/applications/$pkgname.desktop"
  install -Dm644 "$srcdir/$pkgname-$pkgver/packaging/PKGBUILD/$pkgname.png" "$pkgdir/usr/share/pixmaps/$pkgname.png"
}
