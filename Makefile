run:
	@love game $(filter-out $@,$(MAKECMDGOALS))

# Prevent "No rule to make target" errors for args
%:
	@:
