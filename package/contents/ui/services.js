.pragma library

// Services answering a GET with the short URL as plain text.
const all = [
    { id: "dagd",    name: "da.gd",   endpoint: "https://da.gd/s?url=" },
    { id: "isgd",    name: "is.gd",   endpoint: "https://is.gd/create.php?format=simple&url=" },
    // Its links show a "deprecated" preview page before redirecting.
    { id: "tinyurl", name: "TinyURL", endpoint: "https://tinyurl.com/api-create.php?url=" },
];

// Services in the configured order; unknown ids are dropped, unlisted services appended.
function ordered(order) {
    const ids = Array.from(order || []);
    const result = ids.map(id => all.find(s => s.id === id)).filter(s => s !== undefined);
    for (const s of all)
        if (!result.includes(s))
            result.push(s);
    return result;
}
