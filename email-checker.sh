#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to validate email format
validate_email() {
    local email=$1
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        echo -e "${RED}Invalid email format${NC}"
        exit 1
    fi
}

# Function to get domain from email
get_domain() {
    local email=$1
    echo "$email" | cut -d'@' -f2
}

# Function to check if required tools are installed
check_dependencies() {
    if ! command -v dig &> /dev/null; then
        echo -e "${RED}Error: 'dig' is not installed. Please install 'dnsutils' or 'bind-utils'${NC}"
        exit 1
    fi
}

# Function to get and analyze MX records
analyze_mx() {
    local domain=$1
    echo -e "${BLUE}Analyzing MX records...${NC}"
    
    # Get MX records
    local mx_records=$(dig +short MX "$domain" | sort -n)
    
    if [ -z "$mx_records" ]; then
        echo -e "${RED}No MX records found${NC}"
        return 1
    fi
    
    echo "$mx_records"
    
    # Analyze MX records to identify provider
    if echo "$mx_records" | grep -i "protection.outlook.com\|microsoft" > /dev/null; then
        echo -e "${GREEN}✓ Microsoft service detected from MX records${NC}"
        return 0
    elif echo "$mx_records" | grep -i "google\|googlemail\|aspmx.l.google.com" > /dev/null; then
        echo -e "${GREEN}✓ Google Workspace detected from MX records${NC}"
        return 0
    fi
    
    return 1
}

# Function to get and analyze SPF and TXT records
analyze_spf_txt() {
    local domain=$1
    echo -e "${BLUE}Analyzing SPF and TXT records...${NC}"
    
    # Get TXT records (includes SPF)
    local txt_records=$(dig +short TXT "$domain")
    
    if [ -z "$txt_records" ]; then
        echo -e "${RED}No TXT/SPF records found${NC}"
        return 1
    fi
    
    echo "$txt_records"
    
    # Initialize provider flags
    local microsoft_found=false
    local google_found=false
    
    # Look for specific SPF includes that definitively identify the provider
    if echo "$txt_records" | grep -i "v=spf1.*include:spf.*outlook\.com\|v=spf1.*include:spf.*microsoft\.com\|v=spf1.*include:_spf.*microsoft\.com" > /dev/null; then
        microsoft_found=true
    fi
    
    if echo "$txt_records" | grep -i "v=spf1.*include:_spf\.google\.com\|v=spf1.*include:google\.com" > /dev/null; then
        google_found=true
    fi
    
    # Ignore google-site-verification records
    if [ "$microsoft_found" = true ]; then
        echo -e "${GREEN}✓ Microsoft service detected from SPF records${NC}"
        return 0
    elif [ "$google_found" = true ]; then
        echo -e "${GREEN}✓ Google Workspace detected from SPF records${NC}"
        return 0
    fi
    
    return 1
}

# Check dependencies
check_dependencies

# Ask for email
echo -e "${BLUE}Please enter an email address:${NC}"
read email

# Validate email
validate_email "$email"

# Get domain
domain=$(get_domain "$email")
echo -e "${GREEN}Analyzing domain: $domain${NC}"

# Initialize variables for final result
microsoft_detected=false
google_detected=false

# Check known Microsoft domains first
if [[ "$domain" =~ ^(hotmail|outlook|live|msn|microsoft)\.com$ ]]; then
    echo -e "${GREEN}✓ Known Microsoft domain detected${NC}"
    microsoft_detected=true
fi

# If not a known Microsoft domain, analyze DNS records
if [ "$microsoft_detected" = false ]; then
    # Analyze MX records
    if analyze_mx "$domain"; then
        if echo "$mx_records" | grep -i "protection.outlook.com\|microsoft" > /dev/null; then
            microsoft_detected=true
        elif echo "$mx_records" | grep -i "google\|googlemail\|aspmx" > /dev/null; then
            google_detected=true
        fi
    fi

    # Analyze SPF and TXT records
    analyze_spf_txt "$domain"
fi

# If no specific provider was detected
if [ "$microsoft_detected" = false ] && [ "$google_detected" = false ]; then
    echo -e "${BLUE}This domain appears to use a custom or alternative email service${NC}"
    echo -e "Domain: $domain"
fi

# Show final note
echo -e "\n${GREEN}DNS analysis completed${NC}"
