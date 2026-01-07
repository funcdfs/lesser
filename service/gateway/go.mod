module github.com/funcdfs/lesser/gateway

go 1.25.5

require (
	github.com/funcdfs/lesser/auth v0.0.0
	github.com/funcdfs/lesser/comment v0.0.0
	github.com/funcdfs/lesser/content v0.0.0
	github.com/funcdfs/lesser/interaction v0.0.0
	github.com/funcdfs/lesser/notification v0.0.0
	github.com/funcdfs/lesser/pkg v0.0.0
	github.com/funcdfs/lesser/search v0.0.0
	github.com/funcdfs/lesser/timeline v0.0.0
	github.com/funcdfs/lesser/user v0.0.0
	github.com/golang-jwt/jwt/v5 v5.2.2
	golang.org/x/time v0.14.0
	google.golang.org/grpc v1.78.0
	google.golang.org/protobuf v1.36.10
)

require (
	golang.org/x/net v0.47.0 // indirect
	golang.org/x/sys v0.38.0 // indirect
	golang.org/x/text v0.31.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20251029180050-ab9386a59fda // indirect
)

replace (
	github.com/funcdfs/lesser/auth => ../auth
	github.com/funcdfs/lesser/comment => ../comment
	github.com/funcdfs/lesser/content => ../content
	github.com/funcdfs/lesser/interaction => ../interaction
	github.com/funcdfs/lesser/notification => ../notification
	github.com/funcdfs/lesser/pkg => ../pkg
	github.com/funcdfs/lesser/search => ../search
	github.com/funcdfs/lesser/timeline => ../timeline
	github.com/funcdfs/lesser/user => ../user
)
