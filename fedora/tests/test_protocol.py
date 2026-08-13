from importlib.machinery import SourceFileLoader
from pathlib import Path
import unittest

module = SourceFileLoader("ish582_filter", str(Path(__file__).parents[1] / "cups" / "ish582-filter")).load_module()

class ProtocolTests(unittest.TestCase):
    def test_gs_v0_header_and_24_row_blocks(self):
        data = module.gs_v0(48, 25, bytes(48 * 25))
        self.assertEqual(data[:8], bytes.fromhex("1d76300030001800"))
        second = 8 + 48 * 24
        self.assertEqual(data[second : second + 8], bytes.fromhex("1d76300030001800"))

    def test_model_end_sequences_match_gpd(self):
        self.assertEqual(module.end_page("581"), b"")
        self.assertEqual(module.end_job("581"), bytes.fromhex("1b64051b721b40"))
        self.assertEqual(module.end_page("801"), bytes.fromhex("1d53"))
        self.assertEqual(module.end_job("801"), bytes.fromhex("1d54"))

    def test_cups_arguments_allow_stdin_without_filename(self):
        self.assertEqual(module.cups_arguments(["p", "1", "u", "t", "1", "opts"]), ("-", "opts"))
        self.assertEqual(module.cups_arguments(["p", "1", "u", "t", "1", "opts", "/tmp/job.pdf"]), ("/tmp/job.pdf", "opts"))

    def test_pdf_canvas_is_cropped_and_scaled(self):
        width, height, cropped = module.crop_to_ink(16, 2, bytes([0x03, 0, 0, 0]))
        self.assertEqual((width, height), (2, 1))
        width, height, scaled = module.scale_to_width(width, height, cropped, 8)
        self.assertEqual((width, height, len(scaled)), (8, 4, 4))

    def test_56mm_receipt_page_is_scaled_as_whole_page(self):
        source = bytes([0x80] + [0] * 55) * 100
        width, height, payload = module.prepare_page(448, 100, source, 384, "581")
        self.assertEqual((width, height), (384, 86))
        self.assertEqual(len(payload), 48 * 86)

    def test_quality_command_matches_gpd(self):
        self.assertEqual(module.quality_command("density=0"), b"")
        self.assertEqual(module.quality_command("density=5"), bytes.fromhex("1b61011c700500"))

if __name__ == "__main__":
    unittest.main()
