# Stripe for Elixir

An Elixir library for working with [Stripe](https://stripe.com/).

[![Hex.pm](https://img.shields.io/hexpm/v/stripity_stripe.svg?maxAge=2592000)](https://hex.pm/packages/stripity_stripe) [![Hex.pm](https://img.shields.io/hexpm/dt/stripity_stripe.svg?maxAge=2592000)](https://hex.pm/packages/stripity_stripe)

## 2.x.x status

[![Build Status](https://travis-ci.org/code-corps/stripity_stripe.svg?branch=master)](https://travis-ci.org/code-corps/stripity_stripe) [![Hex Docs](https://img.shields.io/badge/hex-docs-9768d1.svg)](https://hexdocs.pm/stripity_stripe)  [![Inline docs](http://inch-ci.org/github/code-corps/stripity_stripe.svg?branch=master)](http://inch-ci.org/github/code-corps/stripity_stripe?branch=master) [![Coverage Status](https://coveralls.io/repos/github/code-corps/stripity_stripe/badge.svg?branch=master)](https://coveralls.io/github/code-corps/stripity_stripe?branch=master)

## 1.x.x status

[![Build Status](https://travis-ci.org/code-corps/stripity_stripe.svg?branch=1.x.x)](https://travis-ci.org/code-corps/stripity_stripe) [![Hex Docs](https://img.shields.io/badge/hex-docs-9768d1.svg)](https://hexdocs.pm/stripity_stripe/1.6.2) [![Inline docs](http://inch-ci.org/github/code-corps/stripity_stripe.svg?branch=1.x.x)](http://inch-ci.org/github/code-corps/stripity_stripe?branch=1.x.x) [![Coverage Status](https://coveralls.io/repos/github/code-corps/stripity_stripe/badge.svg?branch=1.x.x)](https://coveralls.io/github/code-corps/stripity_stripe?branch=1.x.x)

# Which version should I use?

The old `1.x.x` line of releases has been kept and is being published separately for backwards compatibility, since `2.0` was a complete rewrite. To contribute to that line (bugfixes, mainly), create pull requests against the `1.x.x` branch.

The actively developed line of releases is `2.x.x` and is contained within the `master` branch. New features are being added to this line of releases, so to develop this library further, create pull requests against the master branch.

`:stripity_stripe` | Stripe API Version
------------ | -------------
`2.0.x` | `2018-02-28`
`2.1.x - 2.2.x` | `2018-05-21`
`master` | `2018-11-08`

# Documentation

- [Latest HexDocs](https://hexdocs.pm/stripity_stripe/)

- [1.x.x](https://hexdocs.pm/stripity_stripe/1.6.1/)

## Installation

Install the dependency:

```ex
{:stripity_stripe, "~> 2.0.0"}
```

Next, add to your applications:

_Not necessary if using elixir >= 1.4_

```ex
defp application do
  [applications: [:stripity_stripe]]
end
```

## Configuration

To make API calls, it is necessary to configure your Stripe secret key.

```ex
use Mix.Config

config :stripity_stripe, api_key: "YOUR SECRET KEY"
```

It's possible to use a function or a tuple to resolve the secret:

```ex
config :stripity_stripe, api_key: {MyApp.Secrets, :stripe_secret, []}
# OR
config :stripity_stripe, api_key: fn -> System.get_env("STRIPE_SECRET") end
```

Moreover, if you are using Jason instead of Poison, you can configure the library to use Jason like so:

```ex
config :stripity_stripe, json_library: Jason
```

## Note: Object Expansion

Some Stripe API endpoints support returning related objects via the object expansion query parameter. To take advantage of this feature, stripity_stripe accepts
a list of strings to be passed into `opts` under the `:expand` key indicating which objects should be expanded.

For example, calling `Charge.retrieve("ch_123")` would return a charge without expanding any objects.

```elixir
%Charge{
  id: "ch_123",
  balance_transaction: "txn_123",
  ...
}
```

However if we now include an expansion on the `balance_transaction` field using

```elixir
Charge.retrieve("ch_123", expand: ["balance_transaction"])
```

We will get the full object back as well.

```elixir
%Charge{
  id: "ch_123",
  balance_transaction: %BalanceTransaction{
    id: "txn_123",
    fee: 125,
    ...
  },
  ...
}
```

For details on which objects can be expanded check out the [stripe object expansion](https://stripe.com/docs/api#expanding_objects) docs.

# Documentation for 1.x.x

<details><summary>Click to expand</summary>
<p>

## Stripe API

Works with API version 2015-10-16

## Installation

Install the dependency:

```ex
{:stripity_stripe, "~> 1.6"}
```

Next, add to your applications:

```ex
defp application do
  [applications: [:stripity_stripe]]
end
```

## Configuration

To make API calls, it is necessary to configure your Stripe secret key (and optional platform client id if you are using Stripe Connect):

```ex
use Mix.Config

config :stripity_stripe, secret_key: "YOUR SECRET KEY"
config :stripity_stripe, platform_client_id: "YOUR CONNECT PLATFORM CLIENT ID"
```

## Testing

If you start contributing and you want to run mix test, first you need to export STRIPE_SECRET_KEY environment variable in the same shell as the one you will be running mix test in. All tests have the @tag disabled: false and the test runner is configured to ignore disabled: true. This helps to turn tests on/off when working in them. Most of the tests depends on the order of execution (test random seed = 0) to minimize runtime. I've tried having each tests isolated but this made it take ~10 times longer.

```
export STRIPE_SECRET_KEY="yourkey"
mix test
```

## The API

I've tried to make the API somewhat comprehensive and intuitive. If you'd like to see things in detail be sure to have a look at the tests - they show (generally) the way the API goes together.

In general, if Stripe requires some information for a given API call, you'll find that as part of the arity of the given function. For instance if you want to delete a Customer, you'll find that you *must* pass the id along:

```ex
{:ok, result} = Stripe.Customers.delete "some_id"
```

For optional arguments, you can send in a Keyword list that will get translated to parameters. So if you want to update a Subscription, for instance, you must send in the `customer_id` and `subscription_id` with the list of changes:

```ex
# Change customer to the Premium subscription
{:ok, result} = Stripe.Customers.change_subscription "customer_id", "sub_id", [plan: "premium"]
```

Metadata (metadata:) key is supported on most object type and allow the storage of extra information on the stripe platform. See [test](https://github.com/code-corps/stripity-stripe/blob/master/test/stripe/customer_test.exs) for an example.

That's the rule of thumb with this library. If there are any errors with your call, they will bubble up to you in the `{:error, message}` match.

```ex
# Example of paging through events
{:ok, events} = Stripe.Events.list(key, "", 100) # second arg is a marker for paging

case events[:has_more] do
  true ->
    # retrieve marker
    last = List.last( events[:data] )
    case Stripe.Events.list key, last["id"], 100 do
      {:ok, events} -> events[:data]
      # ...
    end
  false -> events[:data]
end
```

# Connect

Stripe Connect allows you to provide your customers with an easy onboarding to their own Stripe account. This is useful when you run an e-commerce as a service platform. Each merchant can transact using their own account using your platform. Then your platform uses Stripe's API with their own API key obtained in the onboarding process.

First, you need to register your platform on Stripe Connect to obtain a `client_id`. In your account settings, there's a "Connect" tab, select it. Then fill the information to activate your connect platform settings. The select he `client_id` (notice there's one for dev and one for prod), stash this `client_id` in the config file under

```ex
config :stripity_stripe, platform_client_id: "ac_???"
```
or in an env var named `STRIPE_PLATFORM_CLIENT_ID`.

Then you send your users to sign up for the stripe account using a link.

Here's an example of a button to start the workflow:
<a href="https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_32D88BD1qLklliziD7gYQvctJIhWBSQ7&scope=read_write">Connect with Stripe</a>

You can generate this URL using:

```ex
url = Stripe.Connect.generate_button_url csrf_token
```

When the user gets back to your platform, the following url (`redirect_uri` form item on your "Connect" settings) will be used:

```
//yoursvr/your_endpoint?scope=read_write&code=AUTHORIZATION_CODE
```

or

```
//yoursvr/your_endpoint?error=access_denied&error_description=The%20user%20denied%20your%20request
```

Using the code request parameter, you make the following call:

```ex
{:ok, resp} -> Stripe.Connect.oauth_token_callback code
resp[:access_token]
```

`resp` will look like this:
```ex
%{
  token_type: "bearer",
  stripe_publishable_key: PUBLISHABLE_KEY,
  scope: "read_write",
  livemode: false,
  stripe_user_id: USER_ID,
  refresh_token: REFRESH_TOKEN,
  access_token: ACCESS_TOKEN
}
```

You can then pass the `access_token` to the other API modules to act on their behalf.

See a [demo](https://github.com/nicrioux/stripity-connect-phoenix) using the Phoenix framework with the bare minimum to get this working.

## Testing Connect

The tests are currently manual as they require a unique OAuth authorization code per test. You need to obtain this code manually using the stripe connect workflow (that your user would go through using the above url).

First, log in your account. Then go to the following url: https://dashboard.stripe.com/account/applications/settings

Create a connect standalone account. Grab your development `client_id`. Put it in your config file. Enter a redirect url to your endpoint. Capture the "code" request parameter. Pass it to `Stripe.Connect.oauth_token_callback` or `Stripe.Connect.get_token`.

</p>
</details>

# Contributing

Feedback, feature requests, and fixes are welcomed and encouraged.  Please make appropriate use of [Issues](https://github.com/code-corps/stripity-stripe/issues) and [Pull Requests](https://github.com/code-corps/stripity-stripe/pulls).  All code should have accompanying tests.

# License

Please see [LICENSE](LICENSE) for licensing details.

# History

## Statement from original author

Why another Stripe Library? Currently there are a number of them in the Elixir world that are, well just not "done" yet. I started to fork/help but soon it became clear to me that what I wanted was

* an existing/better test story
* an API that didn't just mimic a REST interaction
* a library that was up to date with Elixir > 1.0 and would, you know, actually *compile*.
* function calls that returned a standard `{:ok, result}` or `{:error, message}` response

As I began digging things up with these other libraries it became rather apparent that I was not only tweaking the API, but also ripping out a lot of the existing code... and that usually means I should probably do my own thing. So I did.

## Update

As of October 18th, Rob has graciously handed over the reins to the teams at [Code Corps](https://www.codecorps.org/) and [Strumber](https://strumber.com/). To addresses the concerns Rob mentioned above and update the high level api to work with all of the Stripe API Endpoints, they have since worked to release and stripity_stripe 2.0, which is now the actively developed line of releases.
