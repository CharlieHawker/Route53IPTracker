# Route 53 IP Tracker

IP tracker that pushes an UPSERT A record to AWS Route 53 when the externally-available IP address 
is deemed to have changed. I use it for a Raspberry Pi on my home broadband, but suitable for any Linux 
device on a non-static IP based internet connection.

## Prerequisites

The following steps should be taken to prepare the ground for running the tracker:

- Ensure you have the [AWS CLI tools](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) installed
- Make sure you have run `aws configure` and the user has relevant Route 53 privileges
- Make sure you have already set up a hosted zone for the domain you plan to use in the AWS console 
- Install the excellent [jq](https://stedolan.github.io/jq) JSON processor which the bash script makes use of
- Set up a static IP address for your device on the internal network
- Set up forwarding for any ports you want to expose to the outside world to the static internal IP of your device

## Setup

- Clone the repository into a directory of your choosing
- Create a file `config.json` in the same directory, with the following format:
```
{
  "domainName": "<trackingDomain>",
  "hostedZoneId": "<hostedZoneId>"
}
```

Where `<trackingDomain>` should be replaced with the domain (or subdomain) which you want to track the IP address with 
and `<hostedZoneId>` being the ID of the Route 53 hosted zone for the domain (or subdomain).

- Add a crontab entry to run the `update.sh` bash script every 5 minutes and (optionally) print the results to a log file:
```
*/5 * * * * /path/to/directory/update.sh > /path/to/directory/update.log
```

- *Relax*, your life is now complete. You should now be able to reach the device via any of the ports you set up forwarding for via the domain.
