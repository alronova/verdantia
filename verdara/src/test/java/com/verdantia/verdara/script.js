document.addEventListener('DOMContentLoaded', () => {
  const promptInput = document.getElementById('prompt');
  const generateBtn = document.getElementById('generate');
  const treeImage = document.getElementById('tree-image');

  const generate = async () => {
    const prompt = promptInput.value;
    treeImage.style.display = 'none';
    try {
      const res = await fetch('http://localhost:8080/api/prompt', {
        method: 'POST',
        headers: { 'Content-Type': 'text/plain' },
        body: prompt
      });
      if (!res.ok) throw new Error(res.status);

      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      treeImage.src = url;
      treeImage.style.display = 'block';
    } catch (err) {
      alert('Error: ' + err);
    }
  };

  generateBtn.addEventListener('click', generate);
  promptInput.addEventListener('keydown', function(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      generateBtn.click();
    }
  });
});
