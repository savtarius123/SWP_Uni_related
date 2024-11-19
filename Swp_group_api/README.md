# SWP Group Tool Backend

This is the backend for the SWP Group Tool. It is a RESTful API that provides
endpoints for a flutter frontend to interact with. The endpoints are all
documented by means of Dart doc comments. To generate the documentation, run
`dart doc .` in the root directory of the project.

## Running the server

To run the server, it is necessary to compile the server first. This can be
done by running `dart compile exe bin/server.dart`, resulting in a binary
executable in the `bin` directory. This executable can then be executed to
start the server.

Otherwise there is a Dockerfile in the root directory of the project that can
be used to build a docker image. Running the following command will build the
image:

```bash
docker build -t swp_backend .
```

After the image has been built, it can be run with the following command:

```bash
docker run -ti --rm --name swp_backend -p8080:8080 -p8025:8025 -p1025:1025 \
    swp_backend
```

This will start the server and expose the API on port 8080. The server will
also start a mail server on port 1025 and an accompanying web interface on port
8025, so that emails that contain password reset links, tokens and the like can
be inspected.

## Running the tests

To run the tests, run `dart test` in the root directory of the project.

## Configuration

The server can be configured by means of a configuration file. The configuration
file is 'baked in' at compile time, which may be changed in the future. It can
be found in the `lib/config/` directory. The directory contains a file called
`config.dart` which forms the abstract base class for all configurations. The
actual configuration is then implemented in a file called
`production_config.dart`. All settings must be adjusted in the `Config.internal`
factory constructor.

**Note:** Before running the server for the first time, some configuration
values **must** be set for security reasons. The following values must be set
to sensible values:

* API_HOST: The IP address the server binds to.
* API_PORT: The port the server listens on.
* DEFAULT_ADMIN_EMAIL: The email of the admin user.
* DEFAULT_ADMIN_PASSWORD: The password of the admin user.
* DATABASE_PATH: The path to the SQLite database.
* SMTP_USERNAME: The username for the SMTP server to send mails from.
* SMTP_PASSWORD: The password for the SMTP server to send mails from.
* SMTP_FROM: The email address to send mails from.
* SMTP_HOST: The SMTP server host.
* SMTP_PORT: The SMTP server port.
* SMTP_SECURE_CONNECTION: Whether to use a secure connection.
* SEC_PASSWORD_PEPPER: A pepper to hash passwords with.
* JWT_SECRET: The secret to sign JWTs with.
* JWT_ISSUER: The issuer of the JWTs.

## Database

The server relies on a simple SQLite database, which may require the
installation of the SQLite3 library. Using Ubuntu, this library is called
`libsqlite3-dev`. The dart package manager **will not** install this library
automatically, so it must be installed manually or else the application will
not start. By default the database is stored in the file `/tmp/swp_database.db`.
Again, this parameter may be changed in the aforementioned configuration file.

## API

Generally speaking there are three groups of endpoints, which are contained in
the files found in the `lib/server/routes` directory. Please refer to the
documentation in the respective files for more information. As for the three
categories and their respective endpoints, they are as follows:

1. <server-url>/api/auth: Endpoints for authentication matters.
2. <server-url>/api/user: Endpoints for user management.
3. <server-url>/api/group: Endpoints for group management.

Each endpoint responds with a JSON object, which contains four fields:
data, status, success, and message. The data field contains the actual data
returned by the endpoint, which may be any other nested JSON object. The status
field contains the HTTP status code of the response, which may in some cases be
more specific as the status codes returned per HTTP. This is due to limitations
of the HTTP library used. The success field is a boolean that indicates whether
the request was successful or not. The message field contains a message that
may be displayed to the user, which may be an error message or a success
message.

```json
{
   "data": { ... },
   "status": 100..599,
   "success": true | false,
   "message": "Some message"
   }
}
```

Requests may or may not contain a JSON object in the request body, depending on
the endpoint and the HTTP method used. The request body must be a valid JSON
object, and the request must contain the header `Content-Type: application/json`
to indicate that the request body is a JSON object. The necessary fields of the
request body are documented in the Dart doc comments of the respective endpoint.

### Authentication

The authentication endpoints allow for registered users to authenticate
themselves and retrieve a JSON Web Token (JWT) that can be used to authenticate
further requests, as well as the means to refresh the token or log out.
Unregistered users can also start the registration process by requesting a
registration token, via email and confirm their account using the token. In case
a user has forgotten their password, there are also endpoints to request a
password reset found here. Finally, to access some parts of the API, all
requests must be further accompanied by a special API-token that must be
registered for the Application accessing the API.

For details, see [AuthRouter]

### User

The user endpoints allow for the management of users. This includes retrieving
users either by their ID or email, updating their information, and deleting
them, but not changing their password (see the authentication endpoints for
that). Last but not least, a user's groups can be retrieved, as these are
considered part of the user's information, not the group's.

For details, see [UserRouter]

### Group

The group endpoints allow for the management of groups. This includes creating
new groups, retrieving groups by their ID or name, updating their information,
and deleting them. Furthermore, users can be added to or removed from groups,
and the members of a group can be retrieved.

Again, adding users to a group is a two-step process that requires the user to
be first invited to the group by the group owner. Afterwards the user is added
to the group as a _tentative_ member. The user must then accept the invitation
sent to their email address to become a full member of the group. After a set
period of time (set in the configuration file), the invitation expires and the
user must be re-invited.

For details, see [GroupRouter]