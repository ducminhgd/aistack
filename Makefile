.DEFAULT_GOAL := help

.PHONY: help validate add-marketplace add-marketplace-local install-plugins update-plugins

validate:
	claude plugin validate ./.

add-marketplace:
	claude plugin add-market --scope user https://github.com/ducminhgd/aistack

add-marketplace-local:
	claude plugin add-market-local --scope user ./.

install:
	claude plugin install mgd-swe@mgd-marketplace
	claude plugin install mgd@mgd-marketplace
	claude plugin install mgd-product@mgd-marketplace

update:
	claude plugin update mgd-swe@mgd-marketplace
	claude plugin update mgd@mgd-marketplace
	claude plugin update mgd-product@mgd-marketplace

remove:
	claude plugin remove mgd-swe@mgd-marketplace
	claude plugin remove mgd@mgd-marketplace
	claude plugin remove mgd-product@mgd-marketplace

