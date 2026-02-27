<script lang="ts">
	import { translations, type Locale } from '$lib/i18n';
	import { Globe } from 'lucide-svelte';

	const ROUGH_MULTIPLIERS = [1.12, 1.08, 1.04, 1.0, 0.96, 0.92, 0.88];
	const FINE_MULTIPLIERS = [1.03, 1.02, 1.01, 1.0, 0.99, 0.98, 0.97];

	const VALID_LOCALES: Locale[] = ['en', 'ru'];
	const savedLocale = localStorage.getItem('locale') as Locale;
	let locale = $state<Locale>(VALID_LOCALES.includes(savedLocale) ? savedLocale : 'en');
	let t = $derived(translations[locale]);

	$effect(() => {
		localStorage.setItem('locale', locale);
	});

	let initialFlowRate = $state(0.95);
	let roughSelected = $state<number | null>(null);
	let fineSelected = $state<number | null>(null);
	let roughSkipped = $state(false);

	let roughResult = $derived(
		roughSelected !== null ? +(initialFlowRate * ROUGH_MULTIPLIERS[roughSelected]).toFixed(4) : null
	);

	let effectiveRough = $derived<number | null>(
		roughResult !== null
			? roughResult
			: roughSkipped
				? initialFlowRate
				: null
	);

	let fineResult = $derived(
		effectiveRough !== null && fineSelected !== null
			? +(effectiveRough * FINE_MULTIPLIERS[fineSelected]).toFixed(4)
			: null
	);

	function selectRough(index: number) {
		roughSelected = index;
		roughSkipped = false;
		fineSelected = null;
	}

	function skipRough() {
		roughSelected = null;
		roughSkipped = true;
		fineSelected = null;
	}

	function selectFine(index: number) {
		fineSelected = index;
	}

	function resetRough() {
		roughSelected = null;
		roughSkipped = false;
		fineSelected = null;
	}

	function resetFine() {
		fineSelected = null;
	}

	async function copyToClipboard(value: number) {
		await navigator.clipboard.writeText(value.toString());
	}

	function toggleLocale() {
		locale = locale === 'en' ? 'ru' : 'en';
	}
</script>

<main>
	<header>
		<div class="header-content">
			<div>
				<h1>{t.title}</h1>
				<p class="subtitle">{t.subtitle}</p>
			</div>
			<button class="lang-btn" onclick={toggleLocale} title="Switch language">
				<Globe size={14} strokeWidth={2} />
				{locale === 'en' ? 'RU' : 'EN'}
			</button>
		</div>
	</header>

	<div class="input-row">
		<section class="card input-section">
			<label for="initial-flow">{t.initialFlowRate}</label>
			<input
				id="initial-flow"
				type="number"
				step="0.01"
				bind:value={initialFlowRate}
				onchange={resetRough}
			/>
		</section>
	</div>

	<div class="panels">
		<section class="card panel">
			<div class="pass-header">
				<span class="pass-badge rough">1</span>
				<div>
					<h2>{t.roughTitle}</h2>
					<!-- eslint-disable-next-line svelte/no-at-html-tags -->
					<p class="hint">{@html t.roughHint}</p>
				</div>
				<button
					class="btn skip-btn"
					class:active={roughSkipped}
					onclick={roughSkipped ? resetRough : skipRough}
				>{roughSkipped ? t.reset : t.skipRough}</button>
			</div>

			<div class="tiles">
				{#each ROUGH_MULTIPLIERS as mult, i}
					{@const value = +(initialFlowRate * mult).toFixed(4)}
					<button
						class="tile"
						class:selected={roughSelected === i}
						class:has-circles={roughSelected !== null && i < roughSelected}
						onclick={() => selectRough(i)}
					>
						<span class="tile-value">{value}</span>
						<span class="tile-mult">&times;{mult.toFixed(2)}</span>
					</button>
				{/each}
			</div>

			<div class="result-area">
				{#if roughResult !== null}
					<div class="result">
						<span class="result-label">{t.roughLabel}</span>
						<span class="result-value">{roughResult}</span>
						<button class="btn copy" onclick={() => copyToClipboard(roughResult!)}>{t.copy}</button>
						<button class="btn reset" onclick={resetRough}>{t.reset}</button>
					</div>
				{:else if roughSkipped}
					<div class="result skipped">
						<span class="result-label">{t.skippedNote}</span>
						<span class="result-value">{initialFlowRate}</span>
					</div>
				{/if}
			</div>
		</section>

		<section class="card panel" class:disabled={effectiveRough === null}>
			<div class="pass-header">
				<span class="pass-badge fine">2</span>
				<div>
					<h2>{t.fineTitle}</h2>
					<!-- eslint-disable-next-line svelte/no-at-html-tags -->
					<p class="hint">{@html t.fineHint}</p>
				</div>
			</div>

			<div class="tiles">
				{#each FINE_MULTIPLIERS as mult, i}
					{@const value = effectiveRough !== null ? +(effectiveRough * mult).toFixed(4) : '—'}
					<button
						class="tile"
						class:fine-selected={fineSelected === i}
						class:has-circles={fineSelected !== null && (i < fineSelected || i === fineSelected + 1)}
						disabled={effectiveRough === null}
						onclick={() => selectFine(i)}
					>
						<span class="tile-value">{value}</span>
						<span class="tile-mult">&times;{mult.toFixed(2)}</span>
					</button>
				{/each}
			</div>

			<div class="result-area">
				{#if fineResult !== null}
					<div class="result final">
						<span class="result-label">{t.finalLabel}</span>
						<span class="result-value highlight">{fineResult}</span>
						<button class="btn copy green" onclick={() => copyToClipboard(fineResult!)}>{t.copy}</button>
						<button class="btn reset" onclick={resetFine}>{t.reset}</button>
					</div>
				{/if}
			</div>
		</section>
	</div>

	<footer class="legend">
		<div class="legend-item">
			<span class="swatch has-circles"></span>
			{t.legendCircles}
		</div>
		<div class="legend-item">
			<span class="swatch selected-swatch"></span>
			{t.legendRough}
		</div>
		<div class="legend-item">
			<span class="swatch fine-selected-swatch"></span>
			{t.legendFine}
		</div>
	</footer>
</main>

<style>
	:global(html, body) {
		margin: 0;
		padding: 0;
		overflow: hidden;
		height: 100%;
	}

	:root {
		font-family: 'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif;
		font-size: 15px;
		line-height: 1.5;
		color: #1a1a2e;
		background: #f0f2f5;
	}

	main {
		height: 100vh;
		padding: 1.25rem 1.5rem;
		box-sizing: border-box;
		display: flex;
		flex-direction: column;
		gap: 1rem;
		max-width: 900px;
		margin: 0 auto;
	}

	header {
		text-align: center;
	}

	.header-content {
		display: flex;
		align-items: center;
		justify-content: center;
		position: relative;
	}

	.lang-btn {
		position: absolute;
		right: 0;
		padding: 0.3rem 0.65rem;
		border: 2px solid #e5e7eb;
		border-radius: 8px;
		background: #fff;
		font-size: 0.8rem;
		font-weight: 600;
		cursor: pointer;
		font-family: inherit;
		color: #374151;
		transition: border-color 0.15s, background 0.15s;
	}

	.lang-btn:hover {
		border-color: #6366f1;
		background: #f0f0ff;
	}

	h1 {
		font-size: 1.5rem;
		font-weight: 700;
		margin: 0;
	}

	.subtitle {
		color: #6b7280;
		margin: 0.15rem 0 0;
		font-size: 0.85rem;
	}

	.input-row {
		display: flex;
		justify-content: center;
	}

	.card {
		background: #fff;
		border-radius: 12px;
		padding: 1.25rem;
		box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08), 0 1px 2px rgba(0, 0, 0, 0.06);
	}

	.input-section {
		max-width: 280px;
		width: 100%;
	}

	.input-section label {
		display: block;
		font-weight: 600;
		font-size: 0.8rem;
		color: #6b7280;
		margin-bottom: 0.35rem;
		text-transform: uppercase;
		letter-spacing: 0.03em;
	}

	.input-section input {
		width: 100%;
		padding: 0.5rem 0.65rem;
		font-size: 1.2rem;
		font-weight: 600;
		border: 2px solid #e5e7eb;
		border-radius: 8px;
		outline: none;
		transition: border-color 0.15s;
		box-sizing: border-box;
		background: #f9fafb;
	}

	.input-section input:focus {
		border-color: #6366f1;
		background: #fff;
	}

	.panels {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 1rem;
	}

	.panel {
		display: flex;
		flex-direction: column;
	}

	.panel.disabled {
		opacity: 0.45;
		pointer-events: none;
	}

	.pass-header {
		display: flex;
		align-items: center;
		gap: 0.6rem;
		margin-bottom: 0.75rem;
	}

	.pass-header > div {
		flex: 1;
	}

	.pass-badge {
		width: 28px;
		height: 28px;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		font-weight: 700;
		font-size: 0.85rem;
		color: #fff;
		flex-shrink: 0;
	}

	.pass-badge.rough { background: #6366f1; }
	.pass-badge.fine { background: #10b981; }

	.pass-header h2 {
		font-size: 1rem;
		font-weight: 700;
		margin: 0;
	}

	.hint {
		font-size: 0.75rem;
		color: #9ca3af;
		margin: 0.1rem 0 0;
	}

	.tiles {
		display: flex;
		flex-direction: column;
		gap: 4px;
		flex: 1;
	}

	.tile {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: 0.45rem 0.85rem;
		border: 2px solid #e5e7eb;
		border-radius: 8px;
		background: #f9fafb;
		cursor: pointer;
		transition: all 0.15s;
		font-family: inherit;
	}

	.tile:hover:not(:disabled) {
		border-color: #c7d2fe;
		background: #eef2ff;
	}

	.tile:disabled {
		cursor: default;
	}

	.tile.selected {
		border-color: #6366f1;
		background: #e0e7ff;
	}

	.tile.has-circles {
		border-color: #fca5a5;
		background: #fef2f2;
	}

	.tile.fine-selected {
		border-color: #8b5cf6;
		background: #ede9fe;
	}

	.tile-value {
		font-size: 1rem;
		font-weight: 700;
		font-variant-numeric: tabular-nums;
	}

	.tile-mult {
		font-size: 0.75rem;
		color: #9ca3af;
		font-variant-numeric: tabular-nums;
	}

	.result-area {
		margin-top: 0.75rem;
	}

	.result {
		padding: 0.6rem 0.85rem;
		border-radius: 8px;
		background: #f0f4ff;
		display: flex;
		align-items: center;
		gap: 0.5rem;
		flex-wrap: wrap;
	}

	.result.final {
		background: #ecfdf5;
	}

	.result-label {
		font-size: 0.8rem;
		font-weight: 600;
		color: #6b7280;
	}

	.result-value {
		font-size: 1.1rem;
		font-weight: 700;
		font-variant-numeric: tabular-nums;
	}

	.result-value.highlight {
		color: #059669;
		font-size: 1.25rem;
	}

	.skip-btn {
		padding: 0.25rem 0.65rem;
		background: #f3f4f6;
		color: #6b7280;
		border: 2px solid #e5e7eb;
		border-radius: 6px;
		font-size: 0.75rem;
		font-weight: 600;
		cursor: pointer;
		font-family: inherit;
		transition: all 0.15s;
		white-space: nowrap;
		flex-shrink: 0;
	}

	.skip-btn:hover:not(.active) {
		border-color: #6366f1;
		color: #6366f1;
		background: #f0f0ff;
	}

	.skip-btn.active {
		background: #fef3c7;
		border-color: #f59e0b;
		color: #92400e;
	}

	.skip-btn.active:hover {
		background: #fde68a;
	}

	.result.skipped {
		background: #fffbeb;
	}

	.btn {
		padding: 0.25rem 0.6rem;
		border: none;
		border-radius: 6px;
		font-size: 0.75rem;
		font-weight: 600;
		cursor: pointer;
		transition: opacity 0.15s;
		font-family: inherit;
	}

	.btn:hover { opacity: 0.8; }

	.btn.copy {
		background: #6366f1;
		color: #fff;
		margin-left: auto;
	}

	.btn.copy.green {
		background: #10b981;
	}

	.btn.reset {
		background: #f3f4f6;
		color: #6b7280;
	}

	.legend {
		display: flex;
		gap: 1.5rem;
		justify-content: center;
		flex-wrap: wrap;
	}

	.legend-item {
		display: flex;
		align-items: center;
		gap: 0.4rem;
		font-size: 0.78rem;
		color: #6b7280;
	}

	.swatch {
		width: 14px;
		height: 14px;
		border-radius: 4px;
		border: 2px solid;
		flex-shrink: 0;
	}

	.swatch.has-circles {
		border-color: #fca5a5;
		background: #fef2f2;
	}

	.swatch.selected-swatch {
		border-color: #6366f1;
		background: #e0e7ff;
	}

	.swatch.fine-selected-swatch {
		border-color: #8b5cf6;
		background: #ede9fe;
	}
</style>
