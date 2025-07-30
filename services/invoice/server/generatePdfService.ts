import { NextRequest, NextResponse } from "next/server";
import { getInvoiceTemplate } from "@/lib/helpers";
import { ENV, TAILWIND_CDN } from "@/lib/variables";
import { InvoiceType } from "@/types";

export async function generatePdfService(req: NextRequest) {
	const body: InvoiceType = await req.json();
	let browser;
	let page;

	try {
		const ReactDOMServer = (await import("react-dom/server")).default;
		const templateId = body.details.pdfTemplate;
		const InvoiceTemplate = await getInvoiceTemplate(templateId);
		const htmlTemplate = ReactDOMServer.renderToStaticMarkup(InvoiceTemplate(body));

		const puppeteer = await import("puppeteer");

		browser = await puppeteer.launch({
			executablePath: process.env.PUPPETEER_EXECUTABLE_PATH,
			headless: true,
			args: ["--no-sandbox", "--disable-setuid-sandbox"],
		  });
		  

		page = await browser.newPage();

		await page.setContent(htmlTemplate, {
			waitUntil: ["networkidle0", "domcontentloaded", "load"],
			timeout: 30000,
		});

		await page.addStyleTag({ url: TAILWIND_CDN });

		// FIXED: Convert Uint8Array to Buffer
		const pdfBuffer: Uint8Array = await page.pdf({
			format: "a4",
			printBackground: true,
			preferCSSPageSize: true,
		});

		const buffer = Buffer.from(pdfBuffer); // ✅ Fix applied here

		return new NextResponse(new Blob([buffer], { type: "application/pdf" }), {
			status: 200,
			headers: {
				"Content-Type": "application/pdf",
				"Content-Disposition": "attachment; filename=invoice.pdf",
				"Cache-Control": "no-cache",
				Pragma: "no-cache",
			},
		});
	} catch (error) {
		console.error("PDF Generation Error:", error);
		return new NextResponse(JSON.stringify({ error: "Failed to generate PDF", details: error }), {
			status: 500,
			headers: { "Content-Type": "application/json" },
		});
	} finally {
		if (page) {
			try {
				await page.close();
			} catch (e) {
				console.error("Error closing page:", e);
			}
		}
		if (browser) {
			try {
				await browser.close();
			} catch (e) {
				console.error("Error closing browser:", e);
			}
		}
	}
}
