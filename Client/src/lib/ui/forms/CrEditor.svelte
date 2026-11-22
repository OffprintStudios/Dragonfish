<script lang="ts">
    import DOMPurify from "dompurify";
    import TurndownService from "turndown";

    interface Props {
        name: string,
        placeholder?: string;
    }

    let { name, placeholder = "All great journeys begins with a single step..." }: Props = $props();

    const turndown = new TurndownService({
        headingStyle: 'atx',
        codeBlockStyle: 'fenced',
        emDelimiter: '*',
        strongDelimiter: '**',
    });

    function handlePaste(e: ClipboardEvent) {
        const html = e.clipboardData?.getData('text/html');
        if (!html) return; // Let normal plain-text paste happen naturally
        const cleanHTML = DOMPurify.sanitize(html, {
            FORBID_TAGS: ['style', 'script', 'meta', 'link', 'object', 'embed']
        });

        e.preventDefault();

        const el = e.currentTarget as HTMLTextAreaElement;
        const markdown = turndown.turndown(cleanHTML).trim();

        const start = el.selectionStart ?? el.value.length;
        const end = el.selectionEnd ?? el.value.length;

        el.value = el.value.slice(0, start) + markdown + el.value.slice(end);

        const nextCaret = start + markdown.length;
        queueMicrotask(() => {
          el.setSelectionRange(nextCaret, nextCaret);
        });
    }
</script>

<textarea
    id={name}
    {name}
    onpaste={handlePaste}
    {placeholder}
    class="w-7/12 mx-auto h-full box-border resize-none placeholder:text-cr-select placeholder:relative placeholder:italic placeholder:top-0.5 border-0 bg-transparent focus:ring-0 focus:border-0"
></textarea>