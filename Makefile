all:
ifeq (,$(wildcard ./modules/key_pair/keys/id_rsa))
		@./generate.sh
endif

	@terraform init && \
	terraform apply -auto-approve && \
	terraform output -json > infra.json

ssh:
	@ssh -i modules/key_pair/keys/id_rsa ubuntu@$(shell cat infra.json | jq .public_address.value)

clean:
	@terraform destroy -auto-approve && rm infra.json