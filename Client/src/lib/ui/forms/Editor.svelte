<script lang="ts">
    import { md } from "#lib/util/markdown";
    import DOMPurify from "dompurify";
	import { collapseTextChangeRangesAcrossMultipleVersions } from "typescript";

    interface Props {
        value?: string;
        placeholder?: string;
    }

    let {
        value = $bindable("A whole slew of worlds at your fingertips..."),
        placeholder = "Start writing here"
    }: Props = $props();

    let viewMode = $state<'edit' | 'preview'>('edit');
    let textarea = $state<HTMLTextAreaElement>();

    let renderedHTML = $derived(DOMPurify.sanitize(md.render(value)));
</script>