# Email Provider Checker

This script analyzes email addresses to determine their service provider (Microsoft, Google Workspace, or others) by examining DNS records (MX, TXT, and SPF).

## Features

- Validates email address format
- Checks MX records for provider identification
- Analyzes SPF and TXT records for additional verification
- Detects common email providers:
  - Microsoft services (Outlook, Hotmail, Microsoft 365)
  - Google Workspace
  - Custom/Alternative email providers
- Provides colored output for better readability
- Detailed DNS record information

## Prerequisites

- Unix-like operating system (Linux, macOS)
- Bash shell
- `dig` command-line tool (usually part of the `dnsutils` or `bind-utils` package)

### Installing Prerequisites

#### On Debian/Ubuntu:
```bash
sudo apt-get update
sudo apt-get install dnsutils
```

#### On CentOS/RHEL:
```bash
sudo yum install bind-utils
```

#### On macOS:
The `dig` command should be pre-installed. If not:
```bash
brew install bind
```

## Installation

1. Download the script:
```bash
curl -O https://[your-repository]/check_email.sh
```

2. Make the script executable:
```bash
chmod +x check_email.sh
```

## Usage

1. Run the script:
```bash
./check_email.sh
```

2. Enter an email address when prompted:
```
Please enter an email address:
user@example.com
```

3. The script will analyze the domain and display:
   - Domain being analyzed
   - MX records found
   - SPF/TXT records found
   - Detected email provider

### Example Output

```
Please enter an email address:
user@outlook.com
Analyzing domain: outlook.com
Analyzing MX records...
5 outlook-com.olc.protection.outlook.com.
✓ Microsoft service detected from MX records
Analyzing SPF and TXT records...
[SPF records will be displayed here]
✓ Microsoft service detected from SPF records

DNS analysis completed
```

## Error Handling

The script includes error checking for:
- Invalid email format
- Missing DNS records
- Missing required tools (`dig`)

## Limitations

- Requires internet connection to query DNS records
- Some custom email configurations might not be correctly identified
- DNS queries might be slow depending on network conditions

## Troubleshooting

If you encounter issues:

1. Verify `dig` is installed:
```bash
which dig
```

2. Check if DNS queries work:
```bash
dig +short google.com
```

3. Ensure proper permissions:
```bash
chmod +x check_email.sh
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This script is released under the MIT License. See the LICENSE file for details.

## Author

[Your Name/Organization]

## Version History

- 1.0.0 (2024-10-23)
  - Initial release
  - Basic provider detection
  - DNS record analysis
