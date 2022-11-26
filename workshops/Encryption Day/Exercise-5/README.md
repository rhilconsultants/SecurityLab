# GPG exercise

In this Exercise we will generate a Private and Public GPG keys and use those keys to encrypt files.

## Environment 

create a new GPG working dir :
```bash
$ mkdir $HOME/GPG
$ export GPG_BASE="$HOME/GPG"
$ cd ${GPG_BASE}
```
## Key management

When it comes to keys there are private(secret) keys and public keys. They are paired together. The public key is, as expected, something you can make public and share with others. The private key is like your secret password though, don't share that one with anyone! You might have the public key of many people stored on your computer but the only private key you will probably have is your own.

### List keys stored locally
List public keys you have stored (yours and other people's keys)
```bash
$ gpg --list-keys
```

# List private keys (generally only your own)
```bash
$ gpg --list-secret-keys
```

### Create a new private key

Use the --gen-key flag to create a new secret (private) key. This will walk you through an interactive prompt to fill out the questions like what is your name.

```bash
$ gpg --gen-key
```

### Export a private key
You might want to export your private key in order to back it up somewhere. Don't share your private key with other people though. You can export in armored (ASCII) format and you could actually print it out on paper or write it down since it is human readable and put it in cold storage. Text format may also work better than binary in certain communication mediums.


Find the ID of your key first  
The ID is the hexadecimal number  
```bash
gpg --list-secret-keys
```

This is your private key keep it secret!  
Replace XXXXXXXX with your hexadecimal key ID  

```bash
gpg --export-secret-keys --armor XXXXXXXX > ./my-priv-gpg-key.asc
```

Omitting the --armor flag will give you binary output instead of ASCII
which would result in a slightly smaller file but the ASCII
formatted (armored) can be printed physically, is human readable,
and transfered digitally easier.
Both formats can be imported back in to GPG later

### Exporting a public key
To send your public key to a correspondent you must first export it. The command-line option --export is used to do this. It takes an additional argument identifying the public key to export. As with the --gen-revoke option, either the key ID or any part of the user ID may be used to identify the key to export.
```bash
$ gpg --output ${USER}.gpg --export ${USER}@localhost
```

The key is exported in a binary format, but this can be inconvenient when the key is to be sent though email or published on a web page. GnuPG therefore supports a command-line option --armor[1] that that causes output to be generated in an ASCII-armored format similar to uuencoded documents. In general, any output from GnuPG, e.g., keys, encrypted documents, and signatures, can be ASCII-armored by adding the --armor option.

```bash
$ gpg --armor --export ${USER}@localhost
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v0.9.7 (GNU/Linux)
Comment: For info see http://www.gnupg.org

[...]
-----END PGP PUBLIC KEY BLOCK-----
```

Export the Public key to a file 
```bash
$ gpg --armor --export ${USER}@localhost > ${USER}.gpg
```

### Import a key
If you need to import a key you can use the following command. This is useful if you are on a new computer or a fresh install and you need to import your key from a backup. You can import a public or a private key this way. Typically the only time you will be importing a private key is when restoring a backup of your own private key. The most common case for importing a public key is to store someone else's public key in order to send them a private message or to verify a signature of theirs.

This works the same for binary or ASCII (armored) versions of keys
This is also the same for private and public keys
```bash
gpg --import ./${USER}.gpg
```

You can also directly import a key from a server
For example, import the DevDungeon/NanoDano public GPG key from MIT
```bash
gpg --keyserver pgp.mit.edu  --recv C104CDF0EDA54C82
```

Once a key is imported it should be validated. GnuPG uses a powerful and flexible trust model that does not require you to personally validate each key you import. Some keys may need to be personally validated, however. A key is validated by verifying the key's fingerprint and then signing the key to certify it as a valid key. A key's fingerprint can be quickly viewed with the --fingerprint command-line option, but in order to certify the key you must edit it. 

```bash
$ gpg --edit-key ${USER}@localhost
...
Command> fpr
```

A key's fingerprint is verified with the key's owner. This may be done in person or over the phone or through any other means as long as you can guarantee that you are communicating with the key's true owner. If the fingerprint you get is the same as the fingerprint the key's owner gets, then you can be sure that you have a correct copy of the key.

After checking the fingerprint, you may sign the key to validate it. Since key verification is a weak point in public-key cryptography, you should be extremely careful and always check a key's fingerprint with the owner before signing the key.

```bash
Command> sign
...
Really sign?
```

Once signed you can check the key to list the signatures on it and see the signature that you have added. Every user ID on the key will have one or more self-signatures as well as a signature for each user that has validated the key.

```bash
Command> check
```

## Encrypting 

A public and private key each have a specific role when encrypting and decrypting documents. A public key may be thought of as an open safe. When a correspondent encrypts a document using a public key, that document is put in the safe, the safe shut, and the combination lock spun several times. The corresponding private key is the combination that can reopen the safe and retrieve the document. In other words, only the person who holds the private key can recover a document encrypted using the associated public key.

The procedure for encrypting and decrypting documents is straightforward with this mental model. If you want to encrypt a message to Alice, you encrypt it using Alice's public key, and she decrypts it with her private key. If Alice wants to send you a message, she encrypts it using your public key, and you decrypt it with your key.

To encrypt a document the option --encrypt is used. You must have the public keys of the intended recipients. The software expects the name of the document to encrypt as input or, if omitted, on standard input. The encrypted result is placed on standard output or as specified using the option --output. The document is compressed for additional security in addition to encrypting it. 

```bash
$ gpg --output ca.key.gpg --encrypt --recipient ${USER}@localhost $TLS_BASE/CA/ca.key
```

The --recipient option is used once for each recipient and takes an extra argument specifying the public key to which the document should be encrypted. The encrypted document can only be decrypted by someone with a private key that complements one of the recipients' public keys. In particular, you cannot decrypt a document encrypted by you unless you included your own public key in the recipient list.

## decrypting

To decrypt a message the option --decrypt is used. You need the private key to which the message was encrypted. Similar to the encryption process, the document to decrypt is input, and the decrypted result is output.

```bash
$ gpg --output ca.key --decrypt ca.key.gpg

You need a passphrase to unlock the secret key for
...
Enter passphrase: 
```

Documents may also be encrypted without using public-key cryptography. Instead, only a symmetric cipher is used to encrypt the document. The key used to drive the symmetric cipher is derived from a passphrase supplied when the document is encrypted, and for good security, it should not be the same passphrase that you use to protect your private key. Symmetric encryption is useful for securing documents when the passphrase does not need to be communicated to others. A document can be encrypted with a symmetric cipher by using the --symmetric option.

```bash
$ gpg --output doc.gpg --symmetric doc
```

This is it !!!  
Now you can take it to your organization an see where you can use it 