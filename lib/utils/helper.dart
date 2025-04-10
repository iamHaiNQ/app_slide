String _getBulletSymbol(String listType) {
  switch (listType.toLowerCase()) {
    case 'disc':
      return '•';
    case 'circle':
      return '◦';
    case 'square':
      return '▪';
    case 'decimal':
      return '1.';
    default:
      return '•'; // Mặc định là disc
  }
}