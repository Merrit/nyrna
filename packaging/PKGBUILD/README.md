# PKGBUILD Instructions

```go
1. New release available on GitHub

2. updpkgsums // Generate sha256sums in the PKGBUILD

3. Update .desktop file version number

4. makepkg --printsrcinfo > .SRCINFO // Generate the .SRCINFO (AUR package metadata)

5. git add PKGBUILD .SRCINFO nyrna.desktop

6. git commit -m "useful commit message"

7. git push
```

