install:
	cp -r lib/KV ~/perl5/lib/perl5/
	cp bin/kv ~/bin/kv

clean:
	rm -rf ~/perl5/lib/perl5/KV/

db_init:
	bin/db_init

db_clean:
	rm ~/.kv.db
