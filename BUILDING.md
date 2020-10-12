# Building Nyrna

## Building from Linux

### To Linux

Build dependencies:

- gtk3
- libappindicator3
- zenity
- libxkbcommon-x11

`go build`

### To Windows

Hidden console window:

`env GO111MODULE=on GOOS=windows GOARCH=amd64 go build -ldflags "-H=windowsgui"`

Visible console window:

`env GO111MODULE=on GOOS=windows GOARCH=amd64 go build`



## Building from Windows

### To Windows

Hidden console window:

`go build -ldflags "-H=windowsgui"`

Visible console window:

`go build`
