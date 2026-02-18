document.addEventListener("DOMContentLoaded", function () {
    processShortcuts();
});

function processShortcuts() {
    function capitalize(s) {
        return s && String(s[0]).toUpperCase() + String(s).slice(1);
    }
    const codeEl = document.querySelectorAll("code.markdown");

    codeEl.forEach((el) => {
        const codeLines = el.querySelectorAll("span");
        codeLines.forEach((line) => {
            const newText = line.innerText.replace(
                /\+\+([^+]+)\+\+/g,
                (match, content) => {
                    return `<kbd class="dsp">${(content == "enter" ? "⏎" : "") + capitalize(content)}</kbd>`;
                },
            );
            console.log(newText);
            line.innerHTML = newText;
        });
    });
}
