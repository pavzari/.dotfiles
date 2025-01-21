home := zsh git

stow:
	stow .
	stow -t $(HOME) $(home)

unstow:
	stow -D .
	stow -D -t $(HOME) $(home)

refresh:
	stow --restow .
	stow --restow -t $(HOME) $(home)

